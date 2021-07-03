FROM strimzi/kafka:0.20.1-kafka-2.6.0

USER root:root

# 下载debezium tar  ddd
RUN set -ex; \
   wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql/1.6.0.Final/debezium-connector-mysql-1.6.0.Final-plugin.tar.gz; \
   tar -zxvf debezium-connector-mysql-1.6.0.Final-plugin.tar.gz; \

RUN mkdir -p /opt/kafka/plugins/debezium

COPY ./debezium-connector-mysql/ /opt/kafka/plugins/debezium/

USER 1001