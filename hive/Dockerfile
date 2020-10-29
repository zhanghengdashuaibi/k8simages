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

ENV HIVE_HOME /apache-hive-3.1.2-bin
ARG HADOOP_VERSION=3.2.1
ARG HIVE_VERSION=3.1.2

ARG TAR=hadoop-$HADOOP_VERSION.tar.gz

WORKDIR /

RUN set -eux && \
    yum install -y openssh-server openssh-clients tar which

COPY bootstrap.sh /

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
    chmod 777 /bootstrap.sh && \
    mkdir -p /root/bootstrap && \
    chown -R root:root /root/bootstrap && \
    chmod -R 0770 /root/bootstrap && \
    ln -s /hadoop/etc/hadoop /etc/hadoop/conf && \
    rm -fv "$TAR" && \
    { rm -rf hadoop/share/doc; : ; } && \
    yum autoremove -y && \
    # gets autoremoved, ensure it's added back as Hadoop scripts need it
    yum install -y hostname && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN set -eux && \
    yum install -y wget && \
	wget https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz && \
	tar -xzvf apache-hive-$HIVE_VERSION-bin.tar.gz && \
	copy /hadoop/share/hadoop/common/lib/guava-27.0-jre.jar /apache-hive-3.1.2-bin/lib/ && \
	rm -rf /apache-hive-3.1.2-bin/lib/guava-19.0.jar && \
#	mv apache-hive-$HIVE_VERSION-bin hive && \
	rm apache-hive-$HIVE_VERSION-bin.tar.gz && \
	wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.20/mysql-connector-java-8.0.20.jar -O /apache-hive-3.1.2-bin/lib/mysql-connector-java-8.0.20.jar && \
	yum remove -y wget && \
	yum clean all && \
	rm -rf /var/lib/apt/lists/*

#ENV JAVA_HOME="${JAVA_HOME:-/usr}"
ENV HADOOP_HOME /hadoop
ENV HADOOP_CONF_DIR /hadoop/etc/hadoop
ENV HIVE_HOME /apache-hive-3.1.2-bin
#ENV PATH $JAVA_HOME/bin:$PATH
CMD ["/bootstrap.sh"]
