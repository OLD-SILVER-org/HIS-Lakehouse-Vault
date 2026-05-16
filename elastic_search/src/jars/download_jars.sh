#!/bin/bash

# JAR download script for Lake layer
# Usage: bash download_jars.sh

JAR_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$JAR_DIR"

declare -A JARS=(
    # AWS SDK
    ["aws-java-sdk-bundle-1.12.785.jar"]="https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.785/aws-java-sdk-bundle-1.12.785.jar"

    # Apache Commons
    ["commons-configuration2-2.8.0.jar"]="https://repo1.maven.org/maven2/org/apache/commons/commons-configuration2/2.8.0/commons-configuration2-2.8.0.jar"
    ["commons-logging-1.2.jar"]="https://repo1.maven.org/maven2/commons-logging/commons-logging/1.2/commons-logging-1.2.jar"

    # Flink Connectors
    ["flink-connector-files-1.18.1.jar"]="https://repo1.maven.org/maven2/org/apache/flink/flink-connector-files/1.18.1/flink-connector-files-1.18.1.jar"
    ["flink-connector-hive_2.12-1.18.1.jar"]="https://repo1.maven.org/maven2/org/apache/flink/flink-connector-hive_2.12/1.18.1/flink-connector-hive_2.12-1.18.1.jar"
    ["flink-connector-jdbc-3.1.2-1.18.jar"]="https://repo1.maven.org/maven2/org/apache/flink/flink-connector-jdbc/3.1.2-1.18/flink-connector-jdbc-3.1.2-1.18.jar"
    ["flink-connector-kafka-3.1.0-1.18.jar"]="https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kafka/3.1.0-1.18/flink-connector-kafka-3.1.0-1.18.jar"
    ["flink-sql-connector-hive-3.1.3_2.12-1.18.1.jar"]="https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-hive-3.1.3_2.12/1.18.1/flink-sql-connector-hive-3.1.3_2.12-1.18.1.jar"

    # Hadoop
    ["hadoop-auth-3.3.6.jar"]="https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-auth/3.3.6/hadoop-auth-3.3.6.jar"
    ["hadoop-aws-3.3.6.jar"]="https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.6/hadoop-aws-3.3.6.jar"
    ["hadoop-common-3.3.6.jar"]="https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-common/3.3.6/hadoop-common-3.3.6.jar"
    ["hadoop-hdfs-3.3.6.jar"]="https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-hdfs/3.3.6/hadoop-hdfs-3.3.6.jar"
    ["hadoop-hdfs-client-3.3.6.jar"]="https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-hdfs-client/3.3.6/hadoop-hdfs-client-3.3.6.jar"
    ["hadoop-mapreduce-client-core-3.3.6.jar"]="https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-mapreduce-client-core/3.3.6/hadoop-mapreduce-client-core-3.3.6.jar"
    ["hadoop-shaded-guava-1.1.1.jar"]="https://repo1.maven.org/maven2/org/apache/hadoop/thirdparty/hadoop-shaded-guava/1.1.1/hadoop-shaded-guava-1.1.1.jar"
    ["hadoop-shaded-protobuf_3_7-1.1.1.jar"]="https://repo1.maven.org/maven2/org/apache/hadoop/thirdparty/hadoop-shaded-protobuf_3_7/1.1.1/hadoop-shaded-protobuf_3_7-1.1.1.jar"
    ["hadoop-yarn-common-3.3.6.jar"]="https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-yarn-common/3.3.6/hadoop-yarn-common-3.3.6.jar"

    # Hive
    ["hive-exec-3.1.3.jar"]="https://repo1.maven.org/maven2/org/apache/hive/hive-exec/3.1.3/hive-exec-3.1.3.jar"
    ["libfb303-0.9.3.jar"]="https://repo1.maven.org/maven2/org/apache/thrift/libfb303/0.9.3/libfb303-0.9.3.jar"

    # Iceberg
    ["iceberg-aws-bundle-1.6.1.jar"]="https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-aws-bundle/1.6.1/iceberg-aws-bundle-1.6.1.jar"
    ["iceberg-flink-runtime-1.18-1.6.1.jar"]="https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-flink-runtime-1.18/1.6.1/iceberg-flink-runtime-1.18-1.6.1.jar"
    ["iceberg-spark-runtime-3.5_2.12-1.6.1.jar"]="https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.6.1/iceberg-spark-runtime-3.5_2.12-1.6.1.jar"

    # XML Processing
    ["stax2-api-4.2.1.jar"]="https://repo1.maven.org/maven2/org/codehaus/woodstox/stax2-api/4.2.1/stax2-api-4.2.1.jar"
    ["woodstox-core-5.0.3.jar"]="https://repo1.maven.org/maven2/com/fasterxml/woodstox/woodstox-core/5.0.3/woodstox-core-5.0.3.jar"

    # Elasticsearch
    ["elasticsearch-hadoop-8.13.4.jar"]="https://repo1.maven.org/maven2/org/elasticsearch/elasticsearch-hadoop/8.13.4/elasticsearch-hadoop-8.13.4.jar"
)

echo "=== Downloading JAR files for Lake layer ==="
echo "Target folder: $JAR_DIR"
echo "Total JARs: ${#JARS[@]}"
echo ""

for jar in "${!JARS[@]}"; do
    if [ -f "$jar" ]; then
        echo "--- $jar already exists, skipping."
    else
        echo "+++ Downloading $jar..."
        curl -L -o "$jar" "${JARS[$jar]}"
    fi
done

echo -e "\nDownload complete! All JAR files are ready."
