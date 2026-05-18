FROM apache/spark:3.5.6-scala2.12-java17-ubuntu

USER root

# Copy custom JARs to the default Spark jars directory
COPY jars/*.jar /opt/spark/jars/

RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    pip3 install --no-cache-dir requests python-dotenv && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /tmp/spark-events && \
    chown -R spark:spark /tmp/spark-events && \
    chmod 777 /tmp/spark-events

ENV PYTHONPATH=/opt/spark/python:/opt/spark/python/lib/py4j-0.10.9.7-src.zip
ENV PATH="/opt/spark/bin:${PATH}"

USER spark
