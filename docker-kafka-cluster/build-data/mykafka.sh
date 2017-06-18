#!/bin/sh

. `dirname $0`/common.sh

CLUSTERTYPE="$1";shift
CMD="$1";

CheckClusterType ${CLUSTERTYPE}

pidfile=${KAFKA_LOG_DIRS}/kafka.pid
CLUSTERVOLUME="/kafka-cluster/${CLUSTERTYPE}"

if [ "x${CMD}" = "x" -o "x${CMD}" = "xhelp" ]; then
    echo "need one param!"
    echo "start       start kafka-server"
    echo "stop        stop kafka-server"
    echo "info        list kafka-topics,kafka-brokers"
    echo "CLUSTERTYPE:`GetAllClusterType`"
    exit 0
elif [ "x${CMD}" = "xinfo" ]; then
    #$KAFKA_HOME/bin/kafka-topics.sh --list --zookeeper  $KAFKA_ZOOKEEPER_CONNECT
    echo "=================================================="
    echo "kafka-topics:"
    $KAFKA_HOME/bin/zookeeper-shell.sh  $KAFKA_ZOOKEEPER_CONNECT ls /brokers/topics
    echo "=================================================="
    echo "kafka-brokers-advertise_ip:port=${KAFKA_ADVERTISED_HOST_NAME}:${KAFKA_ADVERTISED_PORT}"
    echo "kafka-brokers-localhost_ip:port=127.0.0.1:${KAFKA_PORT}"
    echo "kafka-brokers-id==>"
    $KAFKA_HOME/bin/zookeeper-shell.sh  $KAFKA_ZOOKEEPER_CONNECT ls /brokers/ids
    echo "kafka-brokers-log==>`grep -w 'Registered broker' ${KAFKA_HOME}/logs/server.log* `"
elif [ "x${CMD}" = "xstart" ]; then
    ${CLUSTERVOLUME}/bin/start-kafka.sh ${pidfile}
elif [ "x${CMD}" = "xstop" ]; then
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
else
    exec $@
fi

