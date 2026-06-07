package flink_streaming_job;

import core.TableProcessor;
import core.JobConfig;
import core.SlackWebhookSender;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.table.api.StatementSet;
import org.apache.flink.table.api.bridge.java.StreamTableEnvironment;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

public abstract class AbstractStreamingBase {

    protected final StreamExecutionEnvironment env;
    protected final StreamTableEnvironment tEnv;
    protected final String catalogName;
    protected final String sinkDatabaseName;
    protected final String kafkaTopicPre;
    protected final String kafkaBootstrapServers;
    protected final String kafkaScanMode;
    protected final Map<String, String> catalogProperties;
    protected final String timezone;

    public AbstractStreamingBase() {
        this.catalogName = JobConfig.get("catalog.name");
        this.sinkDatabaseName = JobConfig.get("sink.database.name");
        this.kafkaTopicPre = JobConfig.get("kafka.topic.prefix");
        this.kafkaBootstrapServers = JobConfig.get("kafka.bootstrap.servers");
        this.kafkaScanMode = JobConfig.get("kafka.scan.startup.mode");
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

        this.env = StreamExecutionEnvironment.getExecutionEnvironment();
        this.tEnv = StreamTableEnvironment.create(env);
        env.setParallelism(1);

        env.enableCheckpointing(30000);
        env.getCheckpointConfig().setMinPauseBetweenCheckpoints(10000);
        env.getCheckpointConfig().setCheckpointTimeout(60000);
        env.getCheckpointConfig().setMaxConcurrentCheckpoints(1);
    }

    protected abstract Map<String, TableProcessor> getTableProcessors();

    // -------------------------------------------------------------------------
    // Timezone helpers (giống AbstractBatchBase)
    // -------------------------------------------------------------------------

    /**
     * Converts config value (e.g. "UTC+7", "UTC+07", "+0700")
     * to canonical SQL offset format e.g. "+0700".
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
            digits = digits + "00";
        if (digits.length() == 3)
            digits = "0" + digits;

        return sign + digits; // e.g. "+0700"
    }

    /**
     * Wraps a SQL timestamp STRING expression so that:
     * '2025-03-09 16:04:54.849 +0700' → kept as-is
     * '2025-03-09 23:18:05.000' → CONCAT(..., ' +0700')
     *
     * Uses ' +' / ' -' (space before sign) to avoid false-positives
     * from the '-' characters in the date part.
     */
    private String normalizeTimestampExpr(String colExpr) {
        String tzOffset = formatTimezoneOffset(this.timezone); // "+0700"
        String stringExpr = String.format("CAST(%s AS STRING)", colExpr);

        // Handle numeric epoch strings (e.g. Debezium microseconds '1741562285000000')
        String epochToTsExpr = String
                .format("DATE_FORMAT(TO_TIMESTAMP_LTZ(CAST(%s AS BIGINT), 6), 'yyyy-MM-dd HH:mm:ss.SSS')", stringExpr);
        // Handle standard timestamp strings
        String formatExpr = String.format("DATE_FORMAT(TRY_CAST(%s AS TIMESTAMP), 'yyyy-MM-dd HH:mm:ss.SSS')", colExpr);

        return String.format(
                "CASE " +
                        "WHEN REGEXP_MATCH(TRIM(%s), '^[0-9]+$') THEN %s " +
                        "WHEN TRIM(%s) LIKE '%% +%%' OR TRIM(%s) LIKE '%% -%%' OR TRIM(%s) LIKE '%%Z' THEN %s " +
                        "ELSE CONCAT(%s, ' %s') END",
                stringExpr, epochToTsExpr, stringExpr, stringExpr, stringExpr, stringExpr, formatExpr, tzOffset);
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

    private String getSourceTableDDL(TableProcessor processor) {
        return String.format("""
                    CREATE TABLE IF NOT EXISTS %s (%s) WITH (
                      'connector' = 'kafka',
                      'topic' = '%s',
                      'properties.bootstrap.servers' = '%s',
                      'properties.group.id' = 'flink_streaming_%s_consumer',
                      'format' = 'json',
                      'json.ignore-parse-errors' = 'true',
                      'scan.startup.mode' = '%s',
                      'properties.fetch.max.bytes' = '104857600',
                      'properties.max.partition.fetch.bytes' = '10485760'
                    )
                """, processor.getSourceTableName(), getJsonSourceSchemaDDL(processor),
                getKafkaTopic(processor), kafkaBootstrapServers,
                processor.getSourceTableName(), kafkaScanMode);
    }

    private String getSinkTableDDL(TableProcessor processor) {
        String schemaWithPartition = processor.getTableSchemaDDL()
                + ",\n  partition_col STRING, op STRING, is_deleted BOOLEAN";
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
     * Với created_at-based partition: normalize timezone trước SUBSTRING
     * để offset suffix không làm lệch slice YYYY-MM.
     */
    private String getPartitionColumnSQL(TableProcessor processor) {
        if (processor.getPartitionKey().equals("partition_col")) {
            String beforeTs = normalizeTimestampExpr("payload.before.created_at");
            String afterTs = normalizeTimestampExpr("payload.after.created_at");
            return String.format("""
                    CASE
                        WHEN payload.op = 'd' THEN SUBSTRING((%s), 1, 7)
                        ELSE SUBSTRING((%s), 1, 7)
                    END""",
                    beforeTs, afterTs);
        }

        return String.format("""
                    CASE
                        WHEN payload.op = 'd' THEN CAST(payload.before.%s AS STRING)
                        ELSE CAST(payload.after.%s AS STRING)
                    END
                """, processor.getPartitionKey(), processor.getPartitionKey());
    }

    private String getInsertSQL(TableProcessor processor) {
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
                """, getSinkTableName(processor), insertColumns,
                getSelectColumnsWithTz(processor),
                getPartitionColumnSQL(processor),
                processor.getSourceTableName());
    }

    // -------------------------------------------------------------------------
    // run()
    // -------------------------------------------------------------------------

    public void run() throws Exception {
        createCatalog();
        createDatabase();
        System.out.println("✅ Step 1 done - Catalog & Database setup.");

        StatementSet statementSet = tEnv.createStatementSet();

        for (Map.Entry<String, TableProcessor> entry : getTableProcessors().entrySet()) {
            String processorName = entry.getKey();
            TableProcessor processor = entry.getValue();
            System.out.println("--- Preparing pipeline for: " + processorName
                    + " (" + processor.getSourceTableName() + ") ---");

            tEnv.useCatalog("default_catalog");
            tEnv.executeSql(getSourceTableDDL(processor));

            tEnv.useCatalog(catalogName);
            tEnv.executeSql(getSinkTableDDL(processor));

            statementSet.addInsertSql(getInsertSQL(processor));
            System.out.println("✅ Pipeline prepared for table: " + processor.getSourceTableName());
        }

        System.out.println("\n🚀 Executing all pipelines in a single Flink job...");
        SlackWebhookSender.sendMessage("🚀 Flink job is starting with " + getTableProcessors().size() + " pipelines.");
        statementSet.execute();
    }

    // -------------------------------------------------------------------------
    // Catalog / Database
    // -------------------------------------------------------------------------

    private void createCatalog() {
        String propertiesString = catalogProperties.entrySet().stream()
                .map(entry -> String.format("'%s' = '%s'", entry.getKey(), entry.getValue()))
                .collect(Collectors.joining(",\n  "));

        String createCatalogSQL = String.format("CREATE CATALOG %s WITH (\n  %s\n)", catalogName, propertiesString);
        try {
            tEnv.executeSql(createCatalogSQL);
            SlackWebhookSender.sendMessage("✅ Catalog created: " + catalogName);
            System.out.println("✅ Catalog created: " + catalogName);
        } catch (Exception e) {
            System.out.println(
                    "ℹ️  Catalog '" + catalogName + "' might already exist. Skipping. Message: " + e.getMessage());
        }
        tEnv.useCatalog(catalogName);
    }

    private void createDatabase() {
        tEnv.executeSql("CREATE DATABASE IF NOT EXISTS " + sinkDatabaseName);
        System.out.println("✅ Database ready: " + sinkDatabaseName);
    }
}