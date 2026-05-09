#!/bin/bash

# JAR download script for Linux/VPS
# Usage: bash download_jars.sh

# Get the script directory and move into it
JAR_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$JAR_DIR"

declare -A JARS=(
    ["aws-java-sdk-bundle-1.12.785.jar"]="https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.785/aws-java-sdk-bundle-1.12.785.jar"
    ["iceberg-spark-runtime-3.5_2.12-1.6.1.jar"]="https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.6.1/iceberg-spark-runtime-3.5_2.12-1.6.1.jar"
    ["iceberg-flink-runtime-1.18-1.6.1.jar"]="https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-flink-runtime-1.18/1.6.1/iceberg-flink-runtime-1.18-1.6.1.jar"
    ["iceberg-aws-bundle-1.6.1.jar"]="https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-aws-bundle/1.6.1/iceberg-aws-bundle-1.6.1.jar"
    ["postgresql-42.7.9.jar"]="https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.9/postgresql-42.7.9.jar"
    ["flink-sql-connector-hive-3.1.3_2.12-1.18.1.jar"]="https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-hive-3.1.3_2.12/1.18.1/flink-sql-connector-hive-3.1.3_2.12-1.18.1.jar"
    ["flink-connector-jdbc-3.1.2-1.18.jar"]="https://repo1.maven.org/maven2/org/apache/flink/flink-connector-jdbc/3.1.2-1.18/flink-connector-jdbc-3.1.2-1.18.jar"
    ["flink-connector-kafka-3.1.0-1.18.jar"]="https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kafka/3.1.0-1.18/flink-connector-kafka-3.1.0-1.18.jar"
    ["hive-exec-3.1.3.jar"]="https://repo1.maven.org/maven2/org/apache/hive/hive-exec/3.1.3/hive-exec-3.1.3.jar"
    ["kafka-clients-3.7.0.jar"]="https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.7.0/kafka-clients-3.7.0.jar"
    ["hadoop-common-3.3.6.jar"]="https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-common/3.3.6/hadoop-common-3.3.6.jar"
    ["hadoop-aws-3.3.6.jar"]="https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.6/hadoop-aws-3.3.6.jar"
)

for jar in "${!JARS[@]}"; do
    if [ -f "$jar" ]; then
        echo "--- File $jar already exists, skipping."
    else
        echo "+++ Downloading $jar..."
        curl -L -o "$jar" "${JARS[$jar]}"
    fi
done

echo -e "\nDownload complete! All JAR files are ready."
