package flink_batch_job;

/*
 * A class abstract for batch job, include common function for batch job ( first ingertion)
 *  
 *  
 * 
 * 
 * 
 * */

import org.apache.flink.table.api.EnvironmentSettings;
import org.apache.flink.table.api.TableEnvironment;
import org.apache.kafka.clients.admin.*;
import org.apache.kafka.common.TopicPartition;
import core.TableProcessor;
import core.JobConfig;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;
import core.SlackWebhookSender;

public abstract class AbstractBatchBase {

    // --- Configuration Fields ---
    protected final TableEnvironment tEnv;
    protected final String catalogName;
    protected final String sinkDatabaseName;
    protected final String kafkaTopicPre;
    protected final String kafkaBootstrapServers;
    protected final String kafkaScanMode;
    protected final Map<String, String> catalogProperties;
    protected int batchStep;
    protected int partitionDivisionSize;

    public AbstractBatchBase() {
        // 1. Load config
        this.catalogName = JobConfig.get("catalog.name");
        this.sinkDatabaseName = JobConfig.get("sink.database.name");
        this.kafkaTopicPre = JobConfig.get("kafka.topic.prefix");
        this.kafkaBootstrapServers = JobConfig.get("kafka.bootstrap.servers");
        this.kafkaScanMode = JobConfig.get("kafka.scan.startup.mode");
        this.batchStep = Integer.parseInt(JobConfig.get("batch.step", "500"));
        this.partitionDivisionSize = Integer.parseInt(JobConfig.get("partition.division.size", "100"));

        // 2. Prepare Catalog Properties
        this.catalogProperties = new HashMap<>();
        catalogProperties.put("type", JobConfig.get("type"));
        catalogProperties.put("catalog-type", JobConfig.get("catalog.type"));
        catalogProperties.put("uri", JobConfig.get("catalog.uri"));
        catalogProperties.put("warehouse", JobConfig.get("catalog.warehouse"));
        catalogProperties.put("s3.endpoint", JobConfig.get("s3.endpoint"));
        catalogProperties.put("s3.access-key-id", JobConfig.get("s3.access-key-id"));
        catalogProperties.put("s3.secret-access-key", JobConfig.get("s3.secret-access-key"));
        catalogProperties.put("s3.region", JobConfig.get("s3.region"));
        catalogProperties.put("io-impl", "org.apache.iceberg.aws.s3.S3FileIO");
        catalogProperties.put("s3.path-style-access", "true");

        // 3. Setup Flink Environment
        EnvironmentSettings settings = EnvironmentSettings.newInstance()
                .inBatchMode() // Set bounded ( Batching) mode
                .build();
        this.tEnv = TableEnvironment.create(settings);

        // 4. Configure Checkpointing
        // env.enableCheckpointing(10000); // 10 seconds
        // env.getCheckpointConfig().setMinPauseBetweenCheckpoints(5000); // 5 seconds
        // env.getCheckpointConfig().setCheckpointTimeout(60000); // 60 seconds
        // env.getCheckpointConfig().setMaxConcurrentCheckpoints(1);
    }

    protected abstract Map<String, TableProcessor> getTableProcessors();

    // --- DDL and SQL Generation Methods ---

    private String getKafkaTopic(TableProcessor processor) {
        return kafkaTopicPre + processor.getSourceTableName();
    }

    private String getSinkTableName(TableProcessor processor) {
        return sinkDatabaseName + "." + processor.getSourceTableName();
    }
    // --- Catalog and Database Management ---

    private void createCatalog() {
        String propertiesString = catalogProperties.entrySet().stream()
                .map(entry -> String.format("'%s' = '%s'", entry.getKey(), entry.getValue()))
                .collect(Collectors.joining(",\n  "));

        String createCatalogSQL = String.format("CREATE CATALOG %s WITH (\n  %s\n)", catalogName, propertiesString);
        System.out.println("Creating catalog:\n" + createCatalogSQL);
        try {
            tEnv.executeSql(createCatalogSQL);
            System.out.println("✅ Catalog created.");
        } catch (Exception e) {
            System.out.println("ℹ️  Catalog '" + catalogName + "' might already exist. Skipping creation. Message: "
                    + e.getMessage());
        }
        tEnv.useCatalog(catalogName);
    }

    private void createDatabase() {
        String sql = "CREATE DATABASE IF NOT EXISTS " + sinkDatabaseName;
        try {
            tEnv.executeSql(sql);
            System.out.println("✅ Database created: " + sinkDatabaseName);
        } catch (Exception e) {
            System.out.println("ℹ️  Database '" + sinkDatabaseName
                    + "' might already exist. Skipping creation. Message: " + e.getMessage());
        }
    }

    private String getJsonSourceSchemaDDL(TableProcessor processor) {
        String fields = processor.getTableSchemaDDL();
        return String.format("""
                    payload ROW<
                        before ROW<%s>,
                        after ROW<%s>,
                        op STRING,
                        ts_ms BIGINT
                    >
                """, fields, fields);
    }

    private String getSourceTableDDL(TableProcessor processor, String sourceTableName, String startOffsetStr,
            String endOffsetStr) {
        return String.format("""
                    CREATE TABLE %s (%s) WITH (
                    'connector' = 'kafka',
                    'topic' = '%s',
                    'properties.bootstrap.servers' = '%s',
                    'properties.group.id' = 'flink_batch_%s_consumer',
                    'format' = 'json',
                    'json.ignore-parse-errors' = 'true',
                    'scan.startup.mode' = 'specific-offsets',
                    'scan.startup.specific-offsets' = '%s',
                    'scan.bounded.mode' = 'specific-offsets',
                    'scan.bounded.specific-offsets' = '%s',
                    'properties.fetch.max.bytes' = '104857600',
                    'properties.max.partition.fetch.bytes' = '10485760'
                    )
                """, sourceTableName, getJsonSourceSchemaDDL(processor),
                getKafkaTopic(processor), kafkaBootstrapServers, processor.getSourceTableName(),
                startOffsetStr, endOffsetStr);
    }

    private String getSinkTableDDL(TableProcessor processor) {
        // Add the 'partition_col' to the schema for the sink table.
        String schemaWithPartition = processor.getTableSchemaDDL()
                + ",\n  partition_col STRING , op STRING, is_deleted BOOLEAN";
        return String.format("""
                    CREATE TABLE %s (%s)
                    PARTITIONED BY (%s)
                    WITH (
                      'format-version' = '2',
                      'write.format.default' = 'parquet',
                      'write.parquet.row-group-size-bytes' = '8388608',
                      'write.parquet.page-size-bytes' = '65536',
                      'write.target-file-size-bytes' = '67108864',
                      'write.distribution-mode' = 'none',
                    'write.commit-empty-snapshot.enabled' = 'false',
                      'write.metadata.delete-after-commit.enabled' = 'true',
                        'max-snapshots' = '100',
                        'snapshot-retention-days' = '1',
                        'write.metadata.previous-versions-max' = '5'
                    )
                """, getSinkTableName(processor), schemaWithPartition, "partition_col");
    }

    /**
     * Generates the SQL expression for the 'partition_col' based on the processor's
     * configuration.
     * If the partition key is a real column in the table (e.g., 'dm_xa_phuong'), it
     * uses that column's value.
     * Otherwise, it defaults to deriving the partition from the 'created_at' field.
     *
     * @param processor The table processor.
     * @return The SQL expression for the partition column.
     */
    private String getPartitionColumnSQL(TableProcessor processor) {
        String partitionKey = processor.getPartitionKey();

        if ("partition_col".equals(partitionKey)) {
            return """
                    CASE
                        WHEN payload.op = 'd' THEN SUBSTRING(payload.before.created_at, 1, 7)
                        ELSE SUBSTRING(payload.after.created_at, 1, 7)
                    END""";
        }

        // Case when partitionKey is not 'created_at' → group by FLOOR
        else {
            System.out.println("⚙️ Partitioning by grouped " + partitionKey);
            return String.format("""
                        CASE
                            WHEN payload.op = 'd' THEN CAST(FLOOR(payload.before.%s / %s) AS STRING)
                            ELSE CAST(FLOOR(payload.after.%s / %s) AS STRING)
                        END
                    """, partitionKey, partitionDivisionSize, partitionKey, partitionDivisionSize);
        }
    }

    /**
     * Generates the INSERT SQL statement to move data from the source Kafka view to
     * the sink Iceberg table.
     * 
     * @param processor            The table processor for schema information.
     * @param batchSourceTableName The name of the temporary source table for this
     *                             batch.
     * @return The complete INSERT INTO ... SELECT ... SQL string.
     */
    private String getInsertSQL(TableProcessor processor, String batchSourceTableName, String startOffsetStr,
            String endOffsetStr) {
        // Add 'partition_col', 'op', and 'is_deleted' to the list of columns for the
        // INSERT statement.
        String insertColumns = processor.getInsertColumns() + ",\n  partition_col,\n  op,\n  is_deleted";

        return String.format(
                """
                        INSERT INTO %s (%s)
                        SELECT /*+ OPTIONS('scan.bounded.mode'='specific-offsets', 'scan.startup.mode'='specific-offsets', 'scan.startup.specific-offsets'='%s', 'scan.bounded.specific-offsets'='%s') */
                          %s,
                          %s AS partition_col,
                          payload.op AS op,
                          CASE
                              WHEN payload.op = 'd' THEN TRUE
                              ELSE FALSE
                          END AS is_deleted
                        FROM default_catalog.default_database.%s
                        """,
                getSinkTableName(processor), insertColumns, startOffsetStr, endOffsetStr,
                processor.getSelectColumns(), getPartitionColumnSQL(processor), batchSourceTableName);
    }

    public void run() throws Exception {
        // Step 1 : create Catalog and Database
        createCatalog();
        createDatabase();
        System.out.println("✅ Step 1 done - Catalog & Database setup.");

        try (KafkaOffsetManager offsetManager = new KafkaOffsetManager(kafkaBootstrapServers)) {
            for (Map.Entry<String, TableProcessor> entry : getTableProcessors().entrySet()) {
                String tableName = entry.getKey();
                TableProcessor processor = entry.getValue();
                String topic = getKafkaTopic(processor);
                System.out.println("\n--- Processing table: " + tableName + " from topic: " + topic + " ---");

                // Step 2: Create Sink Table in Iceberg catalog (once per table)
                tEnv.useCatalog(catalogName);
                System.out.println("Using catalog: " + tEnv.getCurrentCatalog());
                String sinkTableName = getSinkTableName(processor);
                tEnv.executeSql("DROP TABLE IF EXISTS " + sinkTableName).await();
                tEnv.executeSql(getSinkTableDDL(processor)).await();
                System.out.println("✅ Created sink table: " + sinkTableName);

                // System.out.println("Sink Table DDL:\n" + getSinkTableDDL(processor));

                // Step 3: Get offset ranges for the topic
                Map<TopicPartition, Long> startOffsets = offsetManager.getOffsets(topic, OffsetSpec.earliest());
                Map<TopicPartition, Long> endOffsets = offsetManager.getOffsets(topic, OffsetSpec.latest());
                Map<TopicPartition, Long> currentOffsets = new HashMap<>(startOffsets);

                boolean topicIsEmpty = startOffsets.entrySet().stream()
                        .allMatch(e -> e.getValue().equals(endOffsets.get(e.getKey())));
                if (topicIsEmpty) {
                    System.out.println("ℹ️ Topic " + topic + " is empty or has been fully read. Skipping.");
                    continue;
                }

                // Step 4: Process data in batches until all offsets are consumed
                int batchNum = 0;
                boolean finished = false;
                String sourceTableName = processor.getSourceTableName() + "_batch_source";
                while (!finished) {
                    batchNum++;
                    System.out.println("--- Starting Batch #" + batchNum + " for table " + tableName + " ---");

                    Map<TopicPartition, Long> batchEndOffsets = new HashMap<>();
                    boolean hasData = false;

                    for (TopicPartition tp : currentOffsets.keySet()) {
                        long current = currentOffsets.getOrDefault(tp, 0L);
                        long latest = endOffsets.getOrDefault(tp, 0L);

                        if (current < latest) {
                            long endOfBatch = Math.min(current + batchStep, latest);
                            batchEndOffsets.put(tp, endOfBatch);
                            if (endOfBatch > current) {
                                hasData = true;
                            }
                        } else {
                            batchEndOffsets.put(tp, current);
                        }
                    }

                    if (!hasData) {
                        System.out.println("✅ All partitions processed for table " + tableName + ". Finished.");
                        SlackWebhookSender
                                .sendMessage("✅ Batch job completed for table " + tableName + ". All data processed.");
                        finished = true;
                        break;
                    }
                    String startOffsetStr = offsetManager.formatOffsets(currentOffsets);
                    String endOffsetStr = offsetManager.formatOffsets(batchEndOffsets);
                    System.out.println("Batch Start Offsets: " + startOffsetStr);
                    System.out.println("Batch End Offsets:   " + endOffsetStr);
                    // Create source table for batch offsets
                    String sourceDDL = getSourceTableDDL(processor, sourceTableName, startOffsetStr, endOffsetStr);
                    tEnv.useCatalog("default_catalog");
                    tEnv.executeSql(sourceDDL).await();
                    // switch back to sink catalog
                    tEnv.useCatalog(catalogName);
                    String insertSQL = getInsertSQL(processor, sourceTableName, startOffsetStr, endOffsetStr);
                    // System.out.println("Insert SQL:\n" + insertSQL);
                    tEnv.executeSql(insertSQL).await();

                    currentOffsets = batchEndOffsets;
                    System.out.println("✅ Completed Batch #" + batchNum);
                    // Clean up the reusable source table after processing the entire topic
                    tEnv.useCatalog("default_catalog"); // Switch to default catalog to drop the source table
                    tEnv.executeSql("DROP TABLE IF EXISTS " + sourceTableName).await();
                    System.out.println("Cleaned up source table: " + sourceTableName);
                    SlackWebhookSender.sendMessage("✅ Completed Batch #" + batchNum + " for table " + tableName + ".");
                }
            }
        }
        System.out.println("\n🚀 All tables processed successfully!");
        SlackWebhookSender.sendMessage("🚀 All batch jobs completed successfully for all tables!");
    }

}