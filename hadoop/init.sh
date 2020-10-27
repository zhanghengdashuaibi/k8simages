#!/usr/bin/env bash
sed -i "s/@HDFS_MASTER_SERVICE@/$HDFS_MASTER_SERVICE/g" /hadoop/etc/hadoop/core-site.xml
sed -i "s/@HDOOP_YARN_MASTER@/$HDOOP_YARN_MASTER/g" /hadoop/etc/hadoop/yarn-site.xml

HADOOP_NODE="${HADOOP_NODE_TYPE}"

if   [  -z $JMX_EXPORTER_ARG   ]; then
    echo   "no JMX_EXPORTER_ARG"
else
    export HADOOP_NAMENODE_OPTS="$HADOOP_NAMENODE_OPTS $JMX_EXPORTER_ARG"
    export HADOOP_DATANODE_OPTS="$HADOOP_DATANODE_OPTS $JMX_EXPORTER_ARG"
fi

if [ $HADOOP_NODE = "namenode" ]; then
    if [ ! -f "/dfs/name/current/VERSION" ];then
        echo "format namenode"
        hdfs namenode -format
    fi
    echo "Start NameNode ..."
    hdfs namenode
else
    if [ $HADOOP_NODE = "datanode" ]; then
        echo "Start DataNode ..."
        hdfs datanode  -regular
    else
        if [ $HADOOP_NODE = "resourceman" ]; then
            echo "Start Yarn Resource Manager ..."
            yarn resourcemanager
        else
            if [ $HADOOP_NODE = "yarnnode" ]; then
                echo "Start Yarn Resource Node  ..."
                yarn nodemanager
            else
                echo "not recoginized nodetype "
            fi
        fi
    fi
fi