#编译阶段
FROM harisekhon/centos-java:latest as build_base

RUN set -eux && \
    yum install -y openssh-server openssh-clients tar which
    
RUN set -eux && \
    yum install -y wget hostname

COPY project /build/

WORKDIR /build

# 下载debezium tar  ddd
RUN set -ex; \
   wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql/1.6.0.Final/debezium-connector-mysql-1.6.0.Final-plugin.tar.gz; \
   tar -zxvf debezium-connector-mysql-1.6.0.Final-plugin.tar.gz;

#运行阶段
FROM strimzi/kafka:0.20.1-kafka-2.6.0

USER root:root

RUN mkdir -p /opt/kafka/plugins/debezium

COPY --from=build_base /build/debezium-connector-mysql/ /opt/kafka/plugins/debezium/
  
#COPY ./debezium-connector-mysql/ /opt/kafka/plugins/debezium/

USER 1001
