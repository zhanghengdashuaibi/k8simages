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

ENV HIVE_HOME /hive
ARG HADOOP_VERSION=3.2.1
ARG HIVE_VERSION=3.1.2

ARG TAR=hadoop-$HADOOP_VERSION.tar.gz

WORKDIR /

RUN set -eux && \
    yum install -y openssh-server openssh-clients tar which

COPY bootstrap.sh /

RUN set -eux && \
    yum install -y wget && \
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
    ln -s /hadoop/etc/hadoop /etc/hadoop/conf && \
    rm -fv "$TAR" && \
    { rm -rf hadoop/share/doc; : ; } && \
    yum autoremove -y && \
    # gets autoremoved,  ensure it's added back as Hadoop scripts need it
    yum clean all && \
    rm -rf /var/cache/yum

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

RUN set -eux && \
    sed -i 's/${HIVE_METADATA_PASSWORD}/'$HIVE_METADATA_PASSWORD'/g' grep '${HIVE_METADATA_PASSWORD}' -rl $HIVE_HOME/conf && \
    $HADOOP_HOME/bin/hadoop fs -mkdir -p /tmp && \
    $HADOOP_HOME/bin/hadoop fs -mkdir -p /user/hive/warehouse && \
    $HADOOP_HOME/bin/hadoop fs -chmod g+w /tmp && \
    $HADOOP_HOME/bin/hadoop fs -chmod g+w /user/hive/warehouse && \
    $HIVE_HOME/bin/schematool -dbType mysql -initSchema --verbose &> $HADOOP_CONF_DIR/hive-metastore-initialization.out && \
    $HIVE_HOME/bin/hiveserver2 & && \
    $HIVE_HOME/bin/hive --service metastore & && \
    cp $HIVE_HOME/conf/hive-env.sh.template $HIVE_HOME/conf/hive-env.sh && \
    echo "export HADOOP_CLIENT_OPTS=\"-Xmx512m -XX:MaxPermSize=1024m \$HADOOP_CLIENT_OPTS\"" >> $HIVE_HOME/conf/hive-env.sh && \
    # keep running
    sleep infinity


#ENV JAVA_HOME="${JAVA_HOME:-/usr}"
ENV HADOOP_HOME /hadoop
ENV HADOOP_CONF_DIR /hadoop/etc/hadoop
ENV HIVE_HOME /hive
#ENV PATH $JAVA_HOME/bin:$PATH
#CMD ["/bootstrap.sh"]
