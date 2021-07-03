#编译阶段
FROM harisekhon/centos-java:latest as build_base

RUN set -eux && \
    yum install -y openssh-server openssh-clients tar which
    
RUN set -eux && \
    yum install -y wget hostname -o build

COPY project /build/

WORKDIR /build

# 指定容器运行时入口程序 server
ENTRYPOINT ["/build/server"]


#运行阶段
FROM strimzi/kafka:0.20.1-kafka-2.6.0

USER root:root

COPY --from build_base /build/server .
#修改环境变量，使之指向动态库的目录
ENV LD_LIBRARY_PATH=./

# 下载debezium tar  ddd
RUN set -ex; \
   wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql/1.6.0.Final/debezium-connector-mysql-1.6.0.Final-plugin.tar.gz; \
   tar -zxvf debezium-connector-mysql-1.6.0.Final-plugin.tar.gz; \
  
RUN mkdir -p /opt/kafka/plugins/debezium

COPY ./debezium-connector-mysql/ /opt/kafka/plugins/debezium/

USER 1001
