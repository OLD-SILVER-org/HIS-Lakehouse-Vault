package flink_batch_job;

import org.apache.flink.table.api.EnvironmentSettings;
import org.apache.flink.table.api.TableEnvironment;
import org.apache.kafka.clients.admin.*;
import org.apache.kafka.common.TopicPartition;
import core.TableProcessor;
import core.JobConfig;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;
import core.SlackWebhookSender;

public abstract class AbstractBatchBase {

    protected final TableEnvironment tEnv;
    protected final String catalogName;
    protected final String sinkDatabaseName;
    protected final String kafkaTopicPre;
    protected final String kafkaBootstrapServers;
    protected final String kafkaScanMode;
    protected final Map<String, String> catalogProperties;
    protected int batchStep;
    protected final String timezone;
    protected int partitionDivisionSize;

    public AbstractBatchBase() {
        this.catalogName = JobConfig.get("catalog.name");
        this.sinkDatabaseName = JobConfig.get("sink.database.name");
        this.kafkaTopicPre = JobConfig.get("kafka.topic.prefix");
        this.kafkaBootstrapServers = JobConfig.get("kafka.bootstrap.servers");
        this.kafkaScanMode = JobConfig.get("kafka.scan.startup.mode");
        this.batchStep = Integer.parseInt(JobConfig.get("batch.step", "500"));
        this.partitionDivisionSize = Integer.parseInt(JobConfig.get("partition.division.size", "100"));
        this.timezone = JobConfig.get("source.timezone", "+0700");

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

        EnvironmentSettings settings = EnvironmentSettings.newInstance()
                .inBatchMode()
                .build();
        this.tEnv = TableEnvironment.create(settings);
    }

    protected abstract Map<String, TableProcessor> getTableProcessors();

    // -------------------------------------------------------------------------
    // Timezone helpers
    // -------------------------------------------------------------------------

    /**
     * Converts config value (e.g. "UTC+7", "UTC+07", "UTC+07:00", "+0700")
     * to canonical SQL offset format "+0700" / "-0700".
     */
    private String formatTimezoneOffset(String tz) {
        String offset = tz.replace("UTC", "").trim();
        if (!offset.startsWith("+") && !offset.startsWith("-"))
            offset = "+" + offset;

        String sign = offset.substring(0, 1);
        String digits = offset.substring(1).replace(":", "");
        if (digits.length() < 2)
            digits = "0" + digits;
        if (digits.length() == 2)
            digits = digits + "00"; // "7" → "700" → "+0700"
        if (digits.length() == 3)
            digits = "0" + digits; // "700" → "0700"

        return sign + digits; // e.g. "+0700"
    }

    /**
     * Wraps a SQL timestamp STRING expression so that:
     * '2025-03-09 16:04:54.849 +0700' → kept as-is
     * '2025-03-09 23:18:05.000' → CONCAT(..., ' +0700')
     *
     * Detection uses ' +' / ' -' (space before sign) to avoid false-positives
     * from the date part which contains '-' without a leading space.
     */
    private String normalizeTimestampExpr(String colExpr) {
        String tzOffset = formatTimezoneOffset(this.timezone); // "+0700"
        String stringExpr = String.format("CAST(%s AS STRING)", colExpr);
        String formatExpr = String.format("DATE_FORMAT(CAST(%s AS TIMESTAMP), 'yyyy-MM-dd HH:mm:ss.SSS')", colExpr);
        return String.format(
                "CASE WHEN TRIM(%s) LIKE '%% +%%' OR TRIM(%s) LIKE '%% -%%' OR TRIM(%s) LIKE '%%Z' " +
                        "THEN %s ELSE CONCAT(%s, ' %s') END",
                stringExpr, stringExpr, stringExpr, stringExpr, formatExpr, tzOffset);
    }
    // -------------------------------------------------------------------------
    // DDL / SQL generation
    // -------------------------------------------------------------------------

    private String getKafkaTopic(TableProcessor processor) {
        return kafkaTopicPre + processor.getSourceTableName();
    }

    private String getSinkTableName(TableProcessor processor) {
        return sinkDatabaseName + "." + processor.getSourceTableName();
    }

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
            System.out.println(
                    "ℹ️  Catalog '" + catalogName + "' might already exist. Skipping. Message: " + e.getMessage());
        }
        tEnv.useCatalog(catalogName);
    }

    private void createDatabase() {
        String sql = "CREATE DATABASE IF NOT EXISTS " + sinkDatabaseName;
        try {
            tEnv.executeSql(sql);
            System.out.println("✅ Database created: " + sinkDatabaseName);
        } catch (Exception e) {
            System.out.println("ℹ️  Database '" + sinkDatabaseName + "' might already exist. Skipping. Message: "
                    + e.getMessage());
        }
    }

    private String getJsonSourceSchemaDDL(TableProcessor processor) {
        String fields = processor.getTableSchemaDDL();
        return String.format("""
                    payload ROW <
                        before ROW<%s>,
                        after ROW<%s>,
                        op STRING,
                        ts_ms BIGINT
                    >
                """, fields, fields);
    }

    private String getSourceTableDDL(TableProcessor processor, String sourceTableName,
            String startOffsetStr, String endOffsetStr) {
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
                    'scan.bounded.specific-offsets' = '%s'
                    )
                """, sourceTableName, getJsonSourceSchemaDDL(processor),
                getKafkaTopic(processor), kafkaBootstrapServers, processor.getSourceTableName(),
                startOffsetStr, endOffsetStr);
    }

    private String getSinkTableDDL(TableProcessor processor) {
        String schemaWithPartition = processor.getTableSchemaDDL()
                + ",\n  partition_col STRING, op STRING, is_deleted BOOLEAN";
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
     * SELECT columns for INSERT — same as TableProcessor.getSelectColumns() but
     * wraps created_at / updated_at with normalizeTimestampExpr() so that rows
     * missing a timezone offset get one appended automatically.
     */
    private String getSelectColumnsWithTz(TableProcessor processor) {
        return Arrays.stream(processor.getTableSchemaDDL().split(","))
                .map(line -> {
                    String columnName = line.trim().split("\\s+")[0];
                    String beforeExpr = "payload.before." + columnName;
                    String afterExpr = "payload.after." + columnName;

                    if (columnName.equals("created_at") || columnName.equals("updated_at")) {
                        beforeExpr = normalizeTimestampExpr(beforeExpr);
                        afterExpr = normalizeTimestampExpr(afterExpr);
                    }

                    return String.format(
                            "CASE WHEN payload.op = 'd' THEN %s ELSE %s END",
                            beforeExpr, afterExpr);
                })
                .collect(Collectors.joining(",\n"));
    }

    /**
     * partition_col expression.
     * For created_at-based partitions: normalize timezone before SUBSTRING so
     * the offset suffix doesn't corrupt the YYYY-MM slice.
     */
    private String getPartitionColumnSQL(TableProcessor processor) {
        String partitionKey = processor.getPartitionKey();

        if ("partition_col".equals(partitionKey)) {
            String beforeTs = normalizeTimestampExpr("payload.before.created_at");
            String afterTs = normalizeTimestampExpr("payload.after.created_at");
            return String.format("""
                    CASE
                        WHEN payload.op = 'd' THEN SUBSTRING((%s), 1, 7)
                        ELSE SUBSTRING((%s), 1, 7)
                    END""",
                    beforeTs, afterTs);
        } else {
            System.out.println("⚙️ Partitioning by grouped " + partitionKey);
            return String.format("""
                    CASE
                        WHEN payload.op = 'd' THEN CAST(FLOOR(payload.before.%s / %s) AS STRING)
                        ELSE CAST(FLOOR(payload.after.%s / %s) AS STRING)
                    END
                    """, partitionKey, partitionDivisionSize, partitionKey, partitionDivisionSize);
        }
    }

    private String getInsertSQL(TableProcessor processor, String batchSourceTableName,
            String startOffsetStr, String endOffsetStr) {
        String insertColumns = processor.getInsertColumns() + ",\n  partition_col,\n  op,\n  is_deleted";

        return String.format(
                """
                        INSERT INTO %s (%s)
                        SELECT /*+ OPTIONS('scan.bounded.mode'='specific-offsets', 'scan.startup.mode'='specific-offsets', 'scan.startup.specific-offsets'='%s', 'scan.bounded.specific-offsets'='%s') */
                        %s,
                        %s AS partition_col,
                        payload.op AS op,
                        CASE WHEN payload.op = 'd' THEN TRUE ELSE FALSE END AS is_deleted
                        FROM default_catalog.default_database.%s
                        """,
                getSinkTableName(processor), insertColumns,
                startOffsetStr, endOffsetStr,
                getSelectColumnsWithTz(processor),
                getPartitionColumnSQL(processor),
                batchSourceTableName);
    }

    // -------------------------------------------------------------------------
    // run()
    // -------------------------------------------------------------------------

    public void run() throws Exception {
        createCatalog();
        createDatabase();
        System.out.println("✅ Step 1 done - Catalog & Database setup.");

        try (KafkaOffsetManager offsetManager = new KafkaOffsetManager(kafkaBootstrapServers)) {
            for (Map.Entry<String, TableProcessor> entry : getTableProcessors().entrySet()) {
                String tableName = entry.getKey();
                TableProcessor processor = entry.getValue();
                String topic = getKafkaTopic(processor);
                System.out.println("\n--- Processing table: " + tableName + " from topic: " + topic + " ---");

                tEnv.useCatalog(catalogName);
                System.out.println("Using catalog: " + tEnv.getCurrentCatalog());
                String sinkTableName = getSinkTableName(processor);
                tEnv.executeSql("DROP TABLE IF EXISTS " + sinkTableName).await();
                tEnv.executeSql(getSinkTableDDL(processor)).await();
                System.out.println("✅ Created sink table: " + sinkTableName);

                Map<TopicPartition, Long> startOffsets = offsetManager.getOffsets(topic, OffsetSpec.earliest());
                Map<TopicPartition, Long> endOffsets = offsetManager.getOffsets(topic, OffsetSpec.latest());
                Map<TopicPartition, Long> currentOffsets = new HashMap<>(startOffsets);

                boolean topicIsEmpty = startOffsets.entrySet().stream()
                        .allMatch(e -> e.getValue().equals(endOffsets.get(e.getKey())));
                if (topicIsEmpty) {
                    System.out.println("ℹ️ Topic " + topic + " is empty. Skipping.");
                    continue;
                }

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
                            if (endOfBatch > current)
                                hasData = true;
                        } else {
                            batchEndOffsets.put(tp, current);
                        }
                    }

                    if (!hasData) {
                        System.out.println("✅ All partitions processed for table " + tableName + ". Finished.");
                        SlackWebhookSender.sendMessage("✅ Batch job completed for table " + tableName + ".");
                        finished = true;
                        break;
                    }

                    String startOffsetStr = offsetManager.formatOffsets(currentOffsets);
                    String endOffsetStr = offsetManager.formatOffsets(batchEndOffsets);
                    System.out.println("Batch Start Offsets: " + startOffsetStr);
                    System.out.println("Batch End Offsets:   " + endOffsetStr);

                    tEnv.useCatalog("default_catalog");
                    tEnv.executeSql(getSourceTableDDL(processor, sourceTableName, startOffsetStr, endOffsetStr))
                            .await();

                    tEnv.useCatalog(catalogName);
                    tEnv.executeSql(getInsertSQL(processor, sourceTableName, startOffsetStr, endOffsetStr)).await();

                    currentOffsets = batchEndOffsets;
                    System.out.println("✅ Completed Batch #" + batchNum);

                    tEnv.useCatalog("default_catalog");
                    tEnv.executeSql("DROP TABLE IF EXISTS " + sourceTableName).await();
                    System.out.println("Cleaned up source table: " + sourceTableName);
                    SlackWebhookSender.sendMessage("✅ Completed Batch #" + batchNum + " for table " + tableName + ".");
                }
            }
        }
        System.out.println("\n🚀 All tables processed successfully!");
        SlackWebhookSender.sendMessage("🚀 All batch jobs completed successfully!");
    }
}