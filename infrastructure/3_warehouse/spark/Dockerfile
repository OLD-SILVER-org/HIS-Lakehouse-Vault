FROM apache/spark:3.5.6-scala2.12-java17-ubuntu

USER root

RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    pip3 install --no-cache-dir requests pyspark python-dotenv && \
    rm -rf /var/lib/apt/lists/*

USER spark
