#!/bin/bash
    set -x
    cd /root/bootstrap

    # Apply custom config file context
    for cfg in ./*; do
      if [[ ! "$cfg" =~ bootstrap.sh ]]; then
        cat $cfg > $HIVE_HOME/conf/${cfg##*/}
      fi
    done

    # Replace hive metadata password
    sed -i 's/${HIVE_METADATA_PASSWORD}/'$HIVE_METADATA_PASSWORD'/g' `grep '${HIVE_METADATA_PASSWORD}' -rl $HIVE_HOME/conf`

    # initSchema
    if [[ ! -e $HADOOP_CONF_DIR/hive-metastore-initialization.out ]]; then
      $HADOOP_HOME/bin/hadoop fs -mkdir -p /tmp
      $HADOOP_HOME/bin/hadoop fs -mkdir -p /user/hive/warehouse
      $HADOOP_HOME/bin/hadoop fs -chmod g+w /tmp
      $HADOOP_HOME/bin/hadoop fs -chmod g+w /user/hive/warehouse

      $HIVE_HOME/bin/schematool -dbType mysql -initSchema --verbose &> $HADOOP_CONF_DIR/hive-metastore-initialization.out
    fi

    $HIVE_HOME/bin/hiveserver2 &
    $HIVE_HOME/bin/hive --service metastore &

    cp $HIVE_HOME/conf/hive-env.sh.template $HIVE_HOME/conf/hive-env.sh && echo "export HADOOP_CLIENT_OPTS=\"-Xmx512m -XX:MaxPermSize=1024m \$HADOOP_CLIENT_OPTS\"" >> $HIVE_HOME/conf/hive-env.sh

    # keep running
    sleep infinity