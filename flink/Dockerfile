###############################################################################
#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
# limitations under the License.
###############################################################################

FROM openjdk:8-jre

ARG HADOOP_VERSION=3.2.1
ARG TAR=hadoop-$HADOOP_VERSION.tar.gz


# Install dependencies
RUN set -ex; \
  apt-get update; \
  apt-get -y install libsnappy1v5 gettext-base; \
  rm -rf /var/lib/apt/lists/*

# Grab gosu for easy step-down from root
ENV GOSU_VERSION 1.11
RUN set -ex; \
  wget -nv -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)"; \
  wget -nv -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc"; \
  export GNUPGHOME="$(mktemp -d)"; \
  for server in ha.pool.sks-keyservers.net $(shuf -e \
                          hkp://p80.pool.sks-keyservers.net:80 \
                          keyserver.ubuntu.com \
                          hkp://keyserver.ubuntu.com:80 \
                          pgp.mit.edu) ; do \
      gpg --batch --keyserver "$server" --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && break || : ; \
  done && \
  gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
  gpgconf --kill all; \
  rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
  chmod +x /usr/local/bin/gosu; \
  gosu nobody true

# Configure Flink version
ENV FLINK_TGZ_URL=https://www.apache.org/dyn/closer.cgi?action=download&filename=flink/flink-1.11.2/flink-1.11.2-bin-scala_2.11.tgz \
    FLINK_ASC_URL=https://www.apache.org/dist/flink/flink-1.11.2/flink-1.11.2-bin-scala_2.11.tgz.asc \
    GPG_KEY=C63E230EFFF519A5BBF2C9AE6767487CD505859C \
    CHECK_GPG=true

# Prepare environment
ENV FLINK_HOME=/opt/flink
ENV PATH=$FLINK_HOME/bin:$PATH
RUN groupadd --system --gid=9999 flink && \
    useradd --system --home-dir $FLINK_HOME --uid=9999 --gid=flink flink
WORKDIR $FLINK_HOME

# Install Flink
RUN set -ex; \
  wget -nv -O flink.tgz "$FLINK_TGZ_URL"; \
  \
  if [ "$CHECK_GPG" = "true" ]; then \
    wget -nv -O flink.tgz.asc "$FLINK_ASC_URL"; \
    export GNUPGHOME="$(mktemp -d)"; \
    for server in ha.pool.sks-keyservers.net $(shuf -e \
                            hkp://p80.pool.sks-keyservers.net:80 \
                            keyserver.ubuntu.com \
                            hkp://keyserver.ubuntu.com:80 \
                            pgp.mit.edu) ; do \
        gpg --batch --keyserver "$server" --recv-keys "$GPG_KEY" && break || : ; \
    done && \
    gpg --batch --verify flink.tgz.asc flink.tgz; \
    gpgconf --kill all; \
    rm -rf "$GNUPGHOME" flink.tgz.asc; \
  fi; \
  \
  tar -xf flink.tgz --strip-components=1; \
  rm flink.tgz; \
  \
  chown -R flink:flink .;

#flink插件包 封装
RUN set -eux && \
  apt-get -y install wget && \
  wget https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-hive-3.1.2_2.11/1.11.2/flink-sql-connector-hive-3.1.2_2.11-1.11.2.jar && \
  wget https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka_2.11/1.11.2/flink-sql-connector-kafka_2.11-1.11.2.jar && \
  wget https://repo1.maven.org/maven2/com/alibaba/ververica/flink-sql-connector-mysql-cdc/1.1.0/flink-sql-connector-mysql-cdc-1.1.0.jar && \
  wget https://repo1.maven.org/maven2/com/alibaba/ververica/flink-format-changelog-json/1.1.0/flink-format-changelog-json-1.1.0.jar && \
  cp /opt/flink/flink-sql-connector-hive-3.1.2_2.11-1.11.2.jar /opt/flink/lib/ && \
  cp /opt/flink/flink-format-changelog-json-1.1.0.jar /opt/flink/lib/ && \
  cp /opt/flink/flink-sql-connector-mysql-cdc-1.1.0.jar /opt/flink/lib/ && \
  cp /opt/flink/flink-sql-connector-kafka_2.11-1.11.2.jar /opt/flink/lib/ && \
#  apt-get remove -y wget && \
#  rm -rf /var/lib/apt/lists/*


#hadoop
RUN set -eux && \
    # --max-redirect - some apache mirrors redirect a couple times and give you the latest version instead
    #                  but this breaks stuff later because the link will not point to the right dir
    #                  (and is also the wrong version for the tag)
    wget -t 10 --max-redirect 1 --retry-connrefused -O "$TAR" "http://www.apache.org/dyn/closer.lua?filename=hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-$HADOOP_VERSION.tar.gz&action=download" || \
    wget -t 10 --max-redirect 1 --retry-connrefused -O "$TAR" "http://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-$HADOOP_VERSION.tar.gz" && \
    tar zxf "$TAR" && \
    # check tarball was extracted to the right place, helps ensure it's the right version and the link will work
    test -d "hadoop-$HADOOP_VERSION" && \
    ln -sv "hadoop-$HADOOP_VERSION" hadoop && \
    mkdir /etc/hadoop && \
    ln -s /hadoop/etc/hadoop /etc/hadoop/conf && \
    rm -fv "$TAR" && \
    { rm -rf hadoop/share/doc; : ; } && \
    apt-get remove -y wget && \
    rm -rf /var/lib/apt/lists/*

#hadoop--->flink
RUN set -eux && \
    cp -r /opt/flink/hadoop/share/hadoop/* /opt/flink/lib/ && \
    chown -R flink:flink . && \
    rm -rf /opt/flink/lib/hdfs/lib/commons-cli-1.2.jar && \
    rm -rf /opt/flink/lib/common/lib/commons-cli-1.2.jar && \
    rm -rf /opt/flink/lib/common/lib/log4j-1.2.17.jar && \
    rm -rf /opt/flink/lib/hdfs/lib/log4j-1.2.17.jar && \
    rm -rf /opt/flink/lib/common/lib/slf4j-log4j12-1.7.25.jar && \
    rm -rf /opt/flink/hadoop && \
    rm -rf /opt/flink/hadoop-3.2.1

# Configure container
COPY docker-entrypoint.sh /
RUN set -eux && \
    chmod 777  /docker-entrypoint.sh && \
    chown -R flink /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 6123 8081
CMD ["help"]