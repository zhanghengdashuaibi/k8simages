#
#  Author: Hari Sekhon
#  Date: 2016-04-24 21:18:57 +0100 (Sun, 24 Apr 2016)
#
#  vim:ts=4:sts=4:sw=4:et
#
#  https://github.com/harisekhon/Dockerfiles
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback
#
#  https://www.linkedin.com/in/harisekhon
#

FROM harisekhon/centos-java:latest
MAINTAINER Hari Sekhon (https://www.linkedin.com/in/harisekhon)

ARG HADOOP_VERSION=3.2.1

ARG HIVE_VERSION=3.1.2

ARG TAR=hadoop-$HADOOP_VERSION.tar.gz

ENV PATH $PATH:/hadoop/bin

LABEL Description="Hadoop Dev" \
      "Hadoop Version"="$HADOOP_VERSION"

WORKDIR /

RUN set -eux && \
    yum install -y openssh-server openssh-clients tar which

#hadoop
RUN set -eux && \
    yum install -y wget hostname && \
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
    yum autoremove -y && \
    # gets autoremoved, ensure it's added back as Hadoop scripts need it
    yum install -y hostname && \
    yum clean all && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /
COPY init.sh /
COPY ./core-site.xml /hadoop/etc/hadoop/core-site.xml
COPY ./hdfs-site.xml /hadoop/etc/hadoop/hdfs-site.xml
COPY ./yarn-site.xml /hadoop/etc/hadoop/yarn-site.xml
COPY ./mapred-site.xml /hadoop/etc/hadoop/mapred-site.xml
COPY ./hadoop.sh /etc/profile.d/hadoop.sh
COPY ./config /root/.ssh/config
COPY ./hadoop-env.sh /hadoop/etc/hadoop/hadoop-env.sh

RUN set -eux && \
    # Hadoop 1.x
    #/hadoop/bin/hadoop namenode -format && \
    # Hadoop 2.x
    /hadoop/bin/hdfs namenode -format && \
    groupadd hadoop && \
    useradd -g hadoop hdfs && \
    useradd -g hadoop yarn && \
    mkdir -p /dfs/name && \
    mkdir -p /dfs/data && \
    mkdir -p /home/hadoop/tmp && \
    mkdir -p /hadoop/logs && \
    chown -R hdfs:hadoop /dfs/name && \
    chown -R hdfs:hadoop /dfs/data && \
    chown -R hdfs:hadoop /home/hadoop/tmp && \
    chgrp -R hadoop /hadoop/logs && \
    chmod -R 0770 /hadoop/logs && \
    mkdir -p /root/.ssh \
          /home/hdfs/.ssh \
          /home/yarn/.ssh && \
    chown hdfs /home/hdfs/.ssh && \
    chown yarn /home/yarn/.ssh && \
    chmod 777  /entrypoint.sh && \
    chmod 777  /init.sh && \
    chmod 0700 /root/.ssh \
               /home/hdfs/.ssh \
               /home/yarn/.ssh

#hive
RUN set -eux && \
    yum install -y wget && \
	wget https://mirrors.tuna.tsinghua.edu.cn/apache/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz && \
	tar -xzvf apache-hive-$HIVE_VERSION-bin.tar.gz && \
	ln -sv "apache-hive-3.1.2-bin" hive && \
	cp /hadoop/share/hadoop/common/lib/guava-27.0-jre.jar /hive/lib/ && \
	rm -rf /hive/lib/guava-19.0.jar && \
#	mv apache-hive-$HIVE_VERSION-bin hive && \
	rm apache-hive-$HIVE_VERSION-bin.tar.gz && \
	wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.20/mysql-connector-java-8.0.20.jar -O /hive/lib/mysql-connector-java-8.0.20.jar && \
	yum remove -y wget && \
	yum clean all && \
	rm -rf /var/lib/apt/lists/*


#COPY ./hive-site.xml /hive/conf/hive-site.xml

#RUN set -eux && \
#    /hadoop/bin/hadoop fs -mkdir -p /tmp && \
#    /hadoop/bin/hadoop fs -mkdir -p /user/hive/warehouse && \
#    /hadoop/bin/hadoop fs -chmod g+w /tmp && \
#    /hadoop/bin/hadoop fs -chmod g+w /user/hive/warehouse

ENV HDFS_NAMENODE_USER=hdfs
ENV HDFS_SECONDARYNAMENODE_USER=hdfs
ENV HDFS_DATANODE_USER=hdfs
ENV YARN_RESOURCEMANAGER_USER=yarn
ENV YARN_NODEMANAGER_USER=yarn
ENV HADOOP_HOME /hadoop
ENV HADOOP_CONF_DIR /hadoop/etc/hadoop
ENV HIVE_HOME /hive
#EXPOSE 8020 8042 8088 9000 10020 19888 50010 50020 50070 50075 50090
# Hadoop 3.0 changed ports :-(
EXPOSE 8020 8042 8088 9000 9868 9870 10020 19888 50010 50020 50090

#CMD ["/entrypoint.sh"]
CMD ["/init.sh"]
