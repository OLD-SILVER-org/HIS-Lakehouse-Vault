# JAR download script for HOSPITAL_DWH Warehouse layer
# Run this script to prepare the environment on a new machine

$JarFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $JarFolder

$Jars = @(
    @{ name = "aws-java-sdk-bundle-1.12.262.jar"; url = "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.262/aws-java-sdk-bundle-1.12.262.jar" },
    @{ name = "iceberg-spark-runtime-3.5_2.12-1.6.1.jar"; url = "https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.6.1/iceberg-spark-runtime-3.5_2.12-1.6.1.jar" },
    @{ name = "iceberg-flink-runtime-1.18-1.6.1.jar"; url = "https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-flink-runtime-1.18/1.6.1/iceberg-flink-runtime-1.18-1.6.1.jar" },
    @{ name = "iceberg-aws-bundle-1.6.1.jar"; url = "https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-aws-bundle/1.6.1/iceberg-aws-bundle-1.6.1.jar" },
    @{ name = "postgresql-42.7.9.jar"; url = "https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.9/postgresql-42.7.9.jar" },
    @{ name = "flink-sql-connector-hive-3.1.3_2.12-1.18.1.jar"; url = "https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-hive-3.1.3_2.12/1.18.1/flink-sql-connector-hive-3.1.3_2.12-1.18.1.jar" },
    @{ name = "flink-connector-jdbc-3.1.2-1.18.jar"; url = "https://repo1.maven.org/maven2/org/apache/flink/flink-connector-jdbc/3.1.2-1.18/flink-connector-jdbc-3.1.2-1.18.jar" },
    @{ name = "flink-connector-kafka-3.1.0-1.18.jar"; url = "https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kafka/3.1.0-1.18/flink-connector-kafka-3.1.0-1.18.jar" },
    @{ name = "hive-exec-3.1.3.jar"; url = "https://repo1.maven.org/maven2/org/apache/hive/hive-exec/3.1.3/hive-exec-3.1.3.jar" },
    @{ name = "hive-common-4.2.0.jar"; url = "https://repo1.maven.org/maven2/org/apache/hive/hive-common/4.2.0/hive-common-4.2.0.jar" },
    @{ name = "hive-metastore-4.2.0.jar"; url = "https://repo1.maven.org/maven2/org/apache/hive/hive-metastore/4.2.0/hive-metastore-4.2.0.jar" },
    @{ name = "kafka-clients-3.7.0.jar"; url = "https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.7.0/kafka-clients-3.7.0.jar" },
    @{ name = "hadoop-aws-3.3.4.jar"; url = "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar" },
    @{ name = "hadoop-shaded-guava-1.1.1.jar"; url = "https://repo1.maven.org/maven2/org/apache/hadoop/thirdparty/hadoop-shaded-guava/1.1.1/hadoop-shaded-guava-1.1.1.jar" },
    @{ name = "commons-configuration2-2.8.0.jar"; url = "https://repo1.maven.org/maven2/org/apache/commons/commons-configuration2/2.8.0/commons-configuration2-2.8.0.jar" },
    @{ name = "commons-logging-1.2.jar"; url = "https://repo1.maven.org/maven2/commons-logging/commons-logging/1.2/commons-logging-1.2.jar" },
    @{ name = "libfb303-0.9.3.jar"; url = "https://repo1.maven.org/maven2/org/apache/thrift/libfb303/0.9.3/libfb303-0.9.3.jar" }
)

foreach ($jar in $Jars) {
    if (Test-Path $jar.name) {
        Write-Host "--- File $($jar.name) already exists, skipping." -ForegroundColor Cyan
    } else {
        Write-Host "+++ Downloading $($jar.name)..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $jar.url -OutFile $jar.name
    }
}

Write-Host "`nDownload complete! All JAR files are ready for Warehouse layer." -ForegroundColor Green
