#!/bin/sh

. `dirname $0`/common.sh

CLUSTERTYPE="$1"
if [ "x$1" != "x" ]; then
    shift
fi
CMD="$1";
CMDOPT="$2";

CheckClusterType ${CLUSTERTYPE}

pidfile=${KAFKA_LOG_DIRS}/kafka.pid
CLUSTERVOLUME="/kafka-cluster/${CLUSTERTYPE}"
hostinfo=`hostname`
istrace=0

#时区修改
tzinfo=""
if [ -f /etc/timezone ]; then
    tzinfo="`cat /etc/timezone`"
fi
if [ "x$tzinfo" != "xAsia/Shanghai" ]; then
    mkdir -p /usr/share/zoneinfo/Asia
    ln -sf ${CLUSTERVOLUME}/bin/TZ_Shanghai /usr/share/zoneinfo/Asia/Shanghai
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
    echo "Asia/Shanghai" > /etc/timezone
fi

#map映射空间大小修改，65536的4倍
MAXMAPCOUNT=$(eval "sysctl vm.max_map_count |awk '{print \$3}'")
if [ "x${MAXMAPCOUNT}" != "x262144" ]; then
    echo "vm.max_map_count=262144" >>/etc/sysctl.conf
fi
#sysctl -w vm.max_map_count=262144,文件系统不可写，会报错
echo "262144" > /writable-proc/sys/vm/max_map_count

#数据目录兼容性处理
if [ ! -d ${KAFKA_LOG_DIRS} ]; then
    mkdir -p ${KAFKA_LOG_DIRS}
fi
if [ ! -d ${KAFKA_LOG_DIRS}/${hostinfo}/datalog ]; then
    mkdir -p ${KAFKA_LOG_DIRS}/${hostinfo}/datalog
fi
if [ ! -d ${KAFKA_LOG_DIRS}/${hostinfo}/log ]; then
    mkdir -p ${KAFKA_LOG_DIRS}/${hostinfo}/log
fi

#处理命令选项
if [ "x${CMDOPT}" = "xon" ]; then
    istrace=1
fi
if [ "x${CMD}" = "xstart" ]; then
    istrace=0
fi

logonoff()
{
    if [ $1 -eq 1 ]; then
        sed 's/INFO/TRACE/g' $KAFKA_HOME/config/log4j.properties > $KAFKA_HOME/config/log4j.properties.1
        mv $KAFKA_HOME/config/log4j.properties.1 $KAFKA_HOME/config/log4j.properties
        sed 's/INFO/TRACE/g' $KAFKA_HOME/config/tools-log4j.properties > $KAFKA_HOME/config/tools-log4j.properties.1
        mv $KAFKA_HOME/config/tools-log4j.properties.1 $KAFKA_HOME/config/tools-log4j.properties
    else
        sed 's/TRACE/INFO/g' $KAFKA_HOME/config/log4j.properties > $KAFKA_HOME/config/log4j.properties.1
        mv $KAFKA_HOME/config/log4j.properties.1 $KAFKA_HOME/config/log4j.properties
        sed 's/TRACE/INFO/g' $KAFKA_HOME/config/tools-log4j.properties > $KAFKA_HOME/config/tools-log4j.properties.1
        mv $KAFKA_HOME/config/tools-log4j.properties.1 $KAFKA_HOME/config/tools-log4j.properties
    fi
}

if [ "x${CMD}" = "x" -o "x${CMD}" = "xhelp" ]; then
    echo "usage: $0 {CLUSTERTYPE} {start|stop|info|topics|bash|log} [args]"
    echo "start       start kafka-server"
    echo "stop        stop kafka-server"
    echo "info        list kafka-topics,kafka-brokers"
    echo "topics      create configurated topics"
    echo "bash        only bash"
    echo "log [on|off] log on or log off"
    echo "CLUSTERTYPE:`GetAllClusterType`"
    exit 0
elif [ "x${CMD}" = "xinfo" ]; then
    #$KAFKA_HOME/bin/kafka-topics.sh --list --zookeeper  $KAFKA_ZOOKEEPER_CONNECT
    echo "=================================================="
    echo "kafka-topics:"
    echo "==>$KAFKA_HOME/bin/zookeeper-shell.sh  $KAFKA_ZOOKEEPER_CONNECT ls /brokers/topics"
    $KAFKA_HOME/bin/zookeeper-shell.sh  $KAFKA_ZOOKEEPER_CONNECT ls /brokers/topics
    echo "==>$KAFKA_HOME/bin/kafka-topics.sh --list --zookeeper $KAFKA_ZOOKEEPER_CONNECT"
    TOPICLIST=$(eval "$KAFKA_HOME/bin/kafka-topics.sh --list --zookeeper $KAFKA_ZOOKEEPER_CONNECT|grep -v ^__")
    echo TOPICLIST="${TOPICLIST}"
    for topic in ${TOPICLIST}
    do
        echo "--------------------------------------------"
        echo "TOPIC [${topic}] Detail:"
        echo "--------------------------------------------"
        echo "==>kafka-topics.sh --zookeeper $KAFKA_ZOOKEEPER_CONNECT --describe --topic ${topic}"
        kafka-topics.sh --zookeeper $KAFKA_ZOOKEEPER_CONNECT --describe --topic ${topic}
    done
    echo "=================================================="
    echo "kafka-brokers:"
    if [[ -z "$KAFKA_ADVERTISED_HOST_NAME" && -n "$HOSTNAME_COMMAND" ]]; then
        export KAFKA_ADVERTISED_HOST_NAME=$(eval $HOSTNAME_COMMAND)
    fi

    if [[ -z "$KAFKA_HOST_NAME" ]]; then
        export KAFKA_HOST_NAME=${KAFKA_ADVERTISED_HOST_NAME}
    fi

    if [[ -z "$KAFKA_ADVERTISED_HOST_NAME" ]]; then
        #export KAFKA_ADVERTISED_HOST_NAME=$(eval "ifconfig eth0|grep -w -i 'inet addr'|awk -F: '{print \$2}'|awk '{print \$1}'")
        export KAFKA_ADVERTISED_HOST_NAME=$(eval "hostname")
    fi

    if [[ -z "$KAFKA_ADVERTISED_LISTENERS" ]]; then
        export KAFKA_ADVERTISED_LISTENERS="PLAINTEXT://${KAFKA_ADVERTISED_HOST_NAME}:${KAFKA_ADVERTISED_PORT}"
        unset KAFKA_ADVERTISED_HOST_NAME
        unset KAFKA_ADVERTISED_PORT
    fi
    echo "kafka-brokers-advertise_ip:port=${KAFKA_ADVERTISED_LISTENERS}"
    echo "kafka-brokers-localhost_ip:port=PLAINTEXT://0.0.0.0:${KAFKA_PORT}"
    echo "kafka-brokers-id==> $KAFKA_HOME/bin/zookeeper-shell.sh  $KAFKA_ZOOKEEPER_CONNECT ls /brokers/ids"
    
    BROKERLIST=$(eval "$KAFKA_HOME/bin/zookeeper-shell.sh  $KAFKA_ZOOKEEPER_CONNECT ls /brokers/ids|sed -n '/WatchedEvent state:/{n;p}'|awk '{print substr(\$0,2,length(\$0)-2)}'|tr ',' ' '")
    echo BROKERLIST="${BROKERLIST}"
    for broker in ${BROKERLIST}
    do
        echo "--------------------------------------------"
        echo "BROKER [${broker}] Detail:"
        echo "--------------------------------------------"
        echo "==>$KAFKA_HOME/bin/zookeeper-shell.sh  $KAFKA_ZOOKEEPER_CONNECT ls /brokers/ids/${broker}"
        $KAFKA_HOME/bin/zookeeper-shell.sh  $KAFKA_ZOOKEEPER_CONNECT ls /brokers/ids/${broker}
    done
    LOGFILE="${CLUSTERVOLUME}/`hostname`/log/server.log*"
    echo "kafka-brokers-log==>`grep -w 'Registered broker' ${LOGFILE}`"
elif [ "x${CMD}" = "xstart" ]; then
    logonoff $istrace
    ${CLUSTERVOLUME}/bin/start-kafka.sh start ${pidfile}
elif [ "x${CMD}" = "xtopics" ]; then
    logonoff $istrace
    ${CLUSTERVOLUME}/bin/start-kafka.sh topcis
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
elif [ "x${CMD}" = "xlog" ]; then
    logonoff $istrace
elif [ "x${CMD}" = "xbash" ]; then
    tail -f /etc/timezone
else
    exec $@
fi

