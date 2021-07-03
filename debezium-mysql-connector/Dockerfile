#编译阶段
FROM harisekhon/centos-java:latest

WORKDIR /

RUN set -eux && \
    yum install -y openssh-server openssh-clients tar which
    
RUN set -eux && \
    yum install -y wget hostname
    
# 下载debezium tar  ddd
RUN set -ex; \
   wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql/1.6.0.Final/debezium-connector-mysql-1.6.0.Final-plugin.tar.gz; \
   tar -zxvf debezium-connector-mysql-1.6.0.Final-plugin.tar.gz; \

FROM strimzi/kafka:0.20.1-kafka-2.6.0

USER root:root
  
RUN mkdir -p /opt/kafka/plugins/debezium

COPY ./debezium-connector-mysql/ /opt/kafka/plugins/debezium/

USER 1001
