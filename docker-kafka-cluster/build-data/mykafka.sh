#!/bin/sh

cmd="$1"
pidfile=${KAFKA_LOG_DIRS}/kafka.pid

if [ "x$1" = "x" ]; then
    echo "need one param!"
    echo "start       start kafka-server"
    echo "stop        stop kafka-server"
    echo "info        list kafka-topics,kafka-brokers"
    exit 10
elif [ "x$1" = "xinfo" ]; then
    #$KAFKA_HOME/bin/kafka-topics.sh --list --zookeeper  $KAFKA_ZOOKEEPER_CONNECT
    echo "=================================================="
    echo "kafka-topics:"
    $KAFKA_HOME/bin/zookeeper-shell.sh  $KAFKA_ZOOKEEPER_CONNECT ls /brokers/topics
    echo "=================================================="
    echo "kafka-brokers:"
    $KAFKA_HOME/bin/zookeeper-shell.sh  $KAFKA_ZOOKEEPER_CONNECT ls /brokers/ids
elif [ "x$1" = "xstart" ]; then
    /kafka-cluster/f2m/bin/start-kafka.sh ${pidfile}
elif [ "x$1" = "xstop" ]; then
    #$KAFKA_HOME/bin/kafka-server-stop.sh
    PIDS=`cat ${pidfile} 2>/dev/null`
    echo "stop kafka server pids=$PIDS"
    if [ -z "$PIDS" ]; then
      echo "No kafka server to stop"
    else
      kill -s TERM $PIDS
      echo "Already Send TERM Signal!"
      #sleep 1
      #while [ 1 ];
      #do
      #  kill -s TERM $PIDS
      #  if [ $? -eq 0 ]; then
      #      echo "kafka server still running..."
      #      sleep 1
      #  else
      #      echo "kafka server is Stopped!"
      #      break;
      #  fi
      #done
    fi
    rm -f ${pidfile} 2>/dev/null
    exit 0
fi

