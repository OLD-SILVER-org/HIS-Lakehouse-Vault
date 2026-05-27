package flink_streaming_job;

import core.TableProcessor;
import core.JobConfig;
import core.SlackWebhookSender;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.table.api.StatementSet;
import org.apache.flink.table.api.bridge.java.StreamTableEnvironment;

import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * An abstract base class for Flink streaming jobs that process multiple tables.
 * It provides the common infrastructure for setting up the Flink streaming
 * environment,
 * managing catalogs, and executing a set of table processing pipelines in a
 * unified job.
 */
public abstract class AbstractStreamingBase {

    // --- Flink & Configuration Fields ---
    protected final StreamExecutionEnvironment env;
    protected final StreamTableEnvironment tEnv;
    protected final String catalogName;
    protected final String sinkDatabaseName;
    protected final String kafkaTopicPre;
    protected final String kafkaBootstrapServers;
    protected final String kafkaScanMode;
    protected final Map<String, String> catalogProperties;

    /**
     * Constructor to initialize the Flink streaming environment and load
     * configurations.
     */
    public AbstractStreamingBase() {
        // 1. Load config from flink-job.properties
        this.catalogName = JobConfig.get("catalog.name");
        this.sinkDatabaseName = JobConfig.get("sink.database.name");
        this.kafkaTopicPre = JobConfig.get("kafka.topic.prefix");
        this.kafkaBootstrapServers = JobConfig.get("kafka.bootstrap.servers");
        this.kafkaScanMode = JobConfig.get("kafka.scan.startup.mode");

        // 2. Prepare Catalog Properties for Iceberg
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

        // 3. Setup Flink Streaming Environment
        this.env = StreamExecutionEnvironment.getExecutionEnvironment();
        this.tEnv = StreamTableEnvironment.create(env);
        env.setParallelism(1); // Default parallelism

        // 4. Configure Checkpointing for fault tolerance and exactly-once sinks
        env.enableCheckpointing(30000);
        env.getCheckpointConfig().setMinPauseBetweenCheckpoints(10000);
        env.getCheckpointConfig().setCheckpointTimeout(60000);
        env.getCheckpointConfig().setMaxConcurrentCheckpoints(1);
    }

    /**
     * Subclasses must implement this method to provide the map of table processors
     * that this specific job will handle.
     * 
     * @return A map where the key is a descriptive name and the value is the
     *         TableProcessor instance.
     */
    protected abstract Map<String, TableProcessor> getTableProcessors();

    /**
     * The main execution logic for the Flink job.
     * It sets up the catalog, database, and then creates and executes the pipelines
     * for all registered table processors as a single, unified job.
     */
    public void run() throws Exception {
        // Step 1: Setup Catalog and Database
        createCatalog();
        createDatabase();
        System.out.println("✅ Step 1 done - Catalog & Database setup.");

        // Use a StatementSet to combine all INSERT statements into a single job graph
        StatementSet statementSet = tEnv.createStatementSet();

        // Step 2, 3, 4: Loop through all processors to create tables and prepare insert
        // statements
        for (Map.Entry<String, TableProcessor> entry : getTableProcessors().entrySet()) {
            String processorName = entry.getKey();
            TableProcessor processor = entry.getValue();
            System.out.println(
                    "--- Preparing pipeline for: " + processorName + " (" + processor.getSourceTableName() + ") ---");

            // Create Source Table in the default catalog
            tEnv.useCatalog("default_catalog");
            tEnv.executeSql(getSourceTableDDL(processor));

            // Create Sink Table in the Iceberg catalog
            tEnv.useCatalog(catalogName);
            tEnv.executeSql(getSinkTableDDL(processor));

            // Add the INSERT statement to the set for later execution
            statementSet.addInsertSql(getInsertSQL(processor));
            System.out.println("✅ Pipeline prepared for table: " + processor.getSourceTableName());
        }

        // Step 5: Execute all INSERT statements in a single, unified job
        System.out.println("\n🚀 Executing all pipelines in a single Flink job...");
        SlackWebhookSender.sendMessage("🚀 Flink job is starting with " + getTableProcessors().size() + " pipelines.");
        statementSet.execute();
    }

    // --- DDL and SQL Generation Methods ---

    private String getKafkaTopic(TableProcessor processor) {
        return kafkaTopicPre + processor.getSourceTableName();
    }

    private String getSinkTableName(TableProcessor processor) {
        return sinkDatabaseName + "." + processor.getSourceTableName();
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

    private String getSourceTableDDL(TableProcessor processor) {
        return String.format("""
                    CREATE TABLE IF NOT EXISTS %s (%s) WITH (
                      'connector' = 'kafka',
                      'topic' = '%s',
                      'properties.bootstrap.servers' = '%s',
                      'properties.group.id' = 'flink_streaming_%s_consumer',
                      'format' = 'json',
                      'json.ignore-parse-errors' = 'true',
                      'scan.startup.mode' = '%s'

                    )
                """, processor.getSourceTableName(), getJsonSourceSchemaDDL(processor), getKafkaTopic(processor),
                kafkaBootstrapServers, processor.getSourceTableName(), kafkaScanMode);
    }

    private String getSinkTableDDL(TableProcessor processor) {
        String schemaWithPartition = processor.getTableSchemaDDL()
                + ",\n  partition_col STRING , op STRING, is_deleted BOOLEAN";

        return String.format("""
                    CREATE TABLE IF NOT EXISTS %s (%s)
                    PARTITIONED BY (%s)
                    WITH (
                      'format-version' = '2',
                      'write.format.default' = 'parquet',
                      'write.commit-empty-snapshot.enabled' = 'false',
                      'write.metadata.delete-after-commit.enabled' = 'true',
                        'max-snapshots' = '100',
                        'snapshot-retention-days' = '1',
                        'write.metadata.previous-versions-max' = '5'

                    )
                """, getSinkTableName(processor), schemaWithPartition, "partition_col");
    }

    private String getPartitionColumnSQL(TableProcessor processor) {
        if (processor.getPartitionKey().equals("partition_col")) {

            return """
                    CASE
                        WHEN payload.op = 'd' THEN SUBSTRING(payload.before.created_at, 1, 7)
                        ELSE SUBSTRING(payload.after.created_at, 1, 7)
                    END""";
        }

        return String.format("""
                    CASE
                        WHEN payload.op = 'd' THEN CAST(payload.before.%s AS STRING)
                        ELSE CAST(payload.after.%s AS STRING)
                    END
                """, processor.getPartitionKey(), processor.getPartitionKey());
    }

    private String getInsertSQL(TableProcessor processor) {
        // The sink table is resolved via `tEnv.useCatalog()`. The source table is in
        // the default catalog.
        String insertColumns = processor.getInsertColumns() + ",\n  partition_col,\n  op,\n  is_deleted";
        return String.format("""
                    INSERT INTO %s (%s)
                    SELECT
                        %s,
                        %s AS partition_col,
                        payload.op AS op,
                        CASE
                            WHEN payload.op = 'd' THEN TRUE
                            ELSE FALSE
                        END AS is_deleted
                    FROM default_catalog.default_database.%s

                """, getSinkTableName(processor), insertColumns, processor.getSelectColumns(),
                getPartitionColumnSQL(processor), processor.getSourceTableName());
    }

    // --- Catalog and Database Management ---

    private void createCatalog() {
        String propertiesString = catalogProperties.entrySet().stream()
                .map(entry -> String.format("'%s' = '%s'", entry.getKey(), entry.getValue()))
                .collect(Collectors.joining(",\n  "));

        String createCatalogSQL = String.format("CREATE CATALOG %s WITH (\n  %s\n)", catalogName, propertiesString);
        try {
            tEnv.executeSql(createCatalogSQL);
            SlackWebhookSender.sendMessage("✅ Catalog created: " + createCatalogSQL);
            System.out.println("✅ Catalog created: " + catalogName);
        } catch (Exception e) {
            // Catalog already exists, which is fine.
            System.out.println("ℹ️  Catalog '" + catalogName + "' might already exist. Skipping creation. Message: "
                    + e.getMessage());
        }
        tEnv.useCatalog(catalogName);
    }

    private void createDatabase() {
        String sql = "CREATE DATABASE IF NOT EXISTS " + sinkDatabaseName;
        tEnv.executeSql(sql);
        System.out.println("✅ Database ready: " + sinkDatabaseName);
    }
}