FROM apache/flink:1.18.1-scala_2.12-java11
SHELL ["/bin/bash", "-c"]

USER flink
WORKDIR /opt/flink
RUN mkdir -p /opt/flink/hadoop-conf

# Copy SQL jobs + Hive config
COPY jobs /opt/flink/jobs
COPY conf/hive-site.xml /opt/flink/conf/hive-site.xml

# # Adjust JobManager address for K8s helm
RUN sed -i "s/jobmanager.rpc.address: localhost/jobmanager.rpc.address: flink-jobmanager/g" ./conf/flink-conf.yaml

# ============================================================
# INSTALL JARS INTO /opt/flink/lib  (not in subfolders)
# ============================================================

# Kafka connector
RUN curl -o /opt/flink/lib/flink-sql-connector-kafka-3.1.0-1.18.jar \
    https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka/3.1.0-1.18/flink-sql-connector-kafka-3.1.0-1.18.jar

# Hive connector
RUN curl -o /opt/flink/lib/flink-sql-connector-hive-3.1.3_2.12-1.18.1.jar \
    https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-hive-3.1.3_2.12/1.18.1/flink-sql-connector-hive-3.1.3_2.12-1.18.1.jar

# Iceberg runtime
RUN curl -o /opt/flink/lib/iceberg-flink-runtime-1.18-1.5.0.jar \
    https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-flink-runtime-1.18/1.5.0/iceberg-flink-runtime-1.18-1.5.0.jar

# Hadoop / AWS S3 support
RUN curl -o /opt/flink/lib/hadoop-aws-3.3.4.jar \
    https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar && \
    curl -o /opt/flink/lib/aws-java-sdk-bundle-1.12.648.jar \
    https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.648/aws-java-sdk-bundle-1.12.648.jar

# Hadoop core dependencies
RUN curl -o /opt/flink/lib/hadoop-hdfs-client-3.3.4.jar \
    https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-hdfs-client/3.3.4/hadoop-hdfs-client-3.3.4.jar && \
    curl -o /opt/flink/lib/hadoop-common-3.3.4.jar \
    https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-common/3.3.4/hadoop-common-3.3.4.jar && \
    curl -o /opt/flink/lib/hadoop-auth-3.3.4.jar \
    https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-auth/3.3.4/hadoop-auth-3.3.4.jar && \
    curl -o /opt/flink/lib/hadoop-shaded-guava-1.1.1.jar \
    https://repo1.maven.org/maven2/org/apache/hadoop/thirdparty/hadoop-shaded-guava/1.1.1/hadoop-shaded-guava-1.1.1.jar && \
    curl -o /opt/flink/lib/woodstox-core-5.3.0.jar \
    https://repo1.maven.org/maven2/com/fasterxml/woodstox/woodstox-core/5.3.0/woodstox-core-5.3.0.jar && \
    curl -o /opt/flink/lib/stax2-api-4.2.1.jar \
    https://repo1.maven.org/maven2/org/codehaus/woodstox/stax2-api/4.2.1/stax2-api-4.2.1.jar

# MapReduce Core
RUN curl -o /opt/flink/lib/hadoop-mapreduce-client-core-3.3.4.jar \
    https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-mapreduce-client-core/3.3.4/hadoop-mapreduce-client-core-3.3.4.jar    

# S3 FS plugin
RUN curl -o /opt/flink/lib/flink-s3-fs-hadoop-1.18.1.jar \
    https://repo1.maven.org/maven2/org/apache/flink/flink-s3-fs-hadoop/1.18.1/flink-s3-fs-hadoop-1.18.1.jar

CMD ./bin/start-cluster.sh && sleep infinity
