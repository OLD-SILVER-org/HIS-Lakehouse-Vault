# JAR download script for HOSPITAL_DWH Lake layer
# Run this script to prepare the environment on a new machine

# Get the directory where the script is located
$JarFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $JarFolder

$Jars = @(
    # AWS SDK
    @{ name = "aws-java-sdk-bundle-1.12.785.jar"; url = "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.785/aws-java-sdk-bundle-1.12.785.jar" },

    # Apache Commons
    @{ name = "commons-configuration2-2.8.0.jar"; url = "https://repo1.maven.org/maven2/org/apache/commons/commons-configuration2/2.8.0/commons-configuration2-2.8.0.jar" },
    @{ name = "commons-logging-1.2.jar"; url = "https://repo1.maven.org/maven2/commons-logging/commons-logging/1.2/commons-logging-1.2.jar" },

    # Flink Connectors
    @{ name = "flink-connector-files-1.18.1.jar"; url = "https://repo1.maven.org/maven2/org/apache/flink/flink-connector-files/1.18.1/flink-connector-files-1.18.1.jar" },
    @{ name = "flink-connector-hive_2.12-1.18.1.jar"; url = "https://repo1.maven.org/maven2/org/apache/flink/flink-connector-hive_2.12/1.18.1/flink-connector-hive_2.12-1.18.1.jar" },
    @{ name = "flink-connector-jdbc-3.1.2-1.18.jar"; url = "https://repo1.maven.org/maven2/org/apache/flink/flink-connector-jdbc/3.1.2-1.18/flink-connector-jdbc-3.1.2-1.18.jar" },
    @{ name = "flink-connector-kafka-3.1.0-1.18.jar"; url = "https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kafka/3.1.0-1.18/flink-connector-kafka-3.1.0-1.18.jar" },
    @{ name = "flink-sql-connector-hive-3.1.3_2.12-1.18.1.jar"; url = "https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-hive-3.1.3_2.12/1.18.1/flink-sql-connector-hive-3.1.3_2.12-1.18.1.jar" },

    # Hadoop
    @{ name = "hadoop-auth-3.3.6.jar"; url = "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-auth/3.3.6/hadoop-auth-3.3.6.jar" },
    @{ name = "hadoop-aws-3.3.6.jar"; url = "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.6/hadoop-aws-3.3.6.jar" },
    @{ name = "hadoop-common-3.3.6.jar"; url = "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-common/3.3.6/hadoop-common-3.3.6.jar" },
    @{ name = "hadoop-hdfs-3.3.6.jar"; url = "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-hdfs/3.3.6/hadoop-hdfs-3.3.6.jar" },
    @{ name = "hadoop-hdfs-client-3.3.6.jar"; url = "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-hdfs-client/3.3.6/hadoop-hdfs-client-3.3.6.jar" },
    @{ name = "hadoop-mapreduce-client-core-3.3.6.jar"; url = "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-mapreduce-client-core/3.3.6/hadoop-mapreduce-client-core-3.3.6.jar" },
    @{ name = "hadoop-shaded-guava-1.1.1.jar"; url = "https://repo1.maven.org/maven2/org/apache/hadoop/thirdparty/hadoop-shaded-guava/1.1.1/hadoop-shaded-guava-1.1.1.jar" },
    @{ name = "hadoop-shaded-protobuf_3_7-1.1.1.jar"; url = "https://repo1.maven.org/maven2/org/apache/hadoop/thirdparty/hadoop-shaded-protobuf_3_7/1.1.1/hadoop-shaded-protobuf_3_7-1.1.1.jar" },
    @{ name = "hadoop-yarn-common-3.3.6.jar"; url = "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-yarn-common/3.3.6/hadoop-yarn-common-3.3.6.jar" },

    # Hive
    @{ name = "hive-exec-3.1.3.jar"; url = "https://repo1.maven.org/maven2/org/apache/hive/hive-exec/3.1.3/hive-exec-3.1.3.jar" },
    @{ name = "libfb303-0.9.3.jar"; url = "https://repo1.maven.org/maven2/org/apache/thrift/libfb303/0.9.3/libfb303-0.9.3.jar" },

    # Iceberg
    @{ name = "iceberg-aws-bundle-1.6.1.jar"; url = "https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-aws-bundle/1.6.1/iceberg-aws-bundle-1.6.1.jar" },
    @{ name = "iceberg-flink-runtime-1.18-1.6.1.jar"; url = "https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-flink-runtime-1.18/1.6.1/iceberg-flink-runtime-1.18-1.6.1.jar" },
    @{ name = "iceberg-spark-runtime-3.5_2.12-1.6.1.jar"; url = "https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.6.1/iceberg-spark-runtime-3.5_2.12-1.6.1.jar" },

    # Kafka
    @{ name = "kafka-clients-3.7.0.jar"; url = "https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.7.0/kafka-clients-3.7.0.jar" },

    # PostgreSQL
    @{ name = "postgresql-42.7.9.jar"; url = "https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.9/postgresql-42.7.9.jar" },

    # XML Processing
    @{ name = "stax2-api-4.2.1.jar"; url = "https://repo1.maven.org/maven2/org/codehaus/woodstox/stax2-api/4.2.1/stax2-api-4.2.1.jar" },
    @{ name = "woodstox-core-5.0.3.jar"; url = "https://repo1.maven.org/maven2/com/fasterxml/woodstox/woodstox-core/5.0.3/woodstox-core-5.0.3.jar" }
)

Write-Host "=== Downloading JAR files for Lake layer ===" -ForegroundColor Green
Write-Host "Target folder: $JarFolder" -ForegroundColor Gray
Write-Host "Total JARs: $($Jars.Count)`n" -ForegroundColor Gray

foreach ($jar in $Jars) {
    if (Test-Path $jar.name) {
        Write-Host "--- $($jar.name) already exists, skipping." -ForegroundColor Cyan
    } else {
        Write-Host "+++ Downloading $($jar.name)..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $jar.url -OutFile $jar.name
    }
}

Write-Host "`nDownload complete! All $($Jars.Count) JAR files are ready." -ForegroundColor Green
