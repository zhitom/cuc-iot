#!/bin/sh
#set -x
. `dirname $0`/common.sh

CLUSTERTYPE="$1"
if [ "x$1" != "x" ]; then
    shift
fi
CMD="$1";
CMDOPT="$2";

CheckClusterType ${CLUSTERTYPE}

CLUSTERVOLUME="/jstorm-cluster/${CLUSTERTYPE}"
#hostinfo=`hostname`
istrace=0

#时区修改
tzinfo=""
if [ -f /etc/timezone ]; then
    tzinfo="`cat /etc/timezone`"
fi
if [ "x$tzinfo" != "xAsia/Shanghai" ]; then
    mkdir -p /usr/share/zoneinfo/Asia
    ln -sf ${CLUSTERVOLUME}/bin/TZ_Shanghai /usr/share/zoneinfo/Asia/Shanghai
    rm -rf /etc/localtime 2>/dev/null
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
    echo "Asia/Shanghai" > /etc/timezone
fi

##map映射空间大小修改，65536的4倍
#MAXMAPCOUNT=$(eval "sysctl vm.max_map_count |awk '{print \$3}'")
#if [ "x${MAXMAPCOUNT}" != "x262144" ]; then
#    echo "vm.max_map_count=262144" >>/etc/sysctl.conf
#fi
##sysctl -w vm.max_map_count=262144,文件系统不可写，会报错
#echo "262144" > /writable-proc/sys/vm/max_map_count

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
        sed 's/INFO/TRACE/g' $JSTORM_HOME/conf/jstorm.log4j.properties > $JSTORM_HOME/conf/jstorm.log4j.properties.1
        mv $JSTORM_HOME/conf/jstorm.log4j.properties.1 $JSTORM_HOME/conf/jstorm.log4j.properties
        sed 's/INFO/TRACE/g' $JSTORM_HOME/conf/client_log4j.properties > $JSTORM_HOME/conf/client_log4j.properties.1
        mv $JSTORM_HOME/conf/client_log4j.properties.1 $JSTORM_HOME/conf/client_log4j.properties
    else
        sed 's/TRACE/INFO/g' $JSTORM_HOME/conf/jstorm.log4j.properties > $JSTORM_HOME/conf/jstorm.log4j.properties.1
        mv $JSTORM_HOME/conf/jstorm.log4j.properties.1 $JSTORM_HOME/conf/jstorm.log4j.properties
        sed 's/TRACE/INFO/g' $JSTORM_HOME/conf/client_log4j.properties > $JSTORM_HOME/conf/client_log4j.properties.1
        mv $JSTORM_HOME/conf/client_log4j.properties.1 $JSTORM_HOME/conf/client_log4j.properties
    fi
}

if [ "x${CMD}" = "x" -o "x${CMD}" = "xhelp" ]; then
    echo "usage: $0 {CLUSTERTYPE} {start|stop|info|bash|log} [args]"
    echo "start       start jstorm-server"
    echo "stop        stop jstorm-server"
    echo "info        list infomations"
    echo "bash        only bash"
    echo "log [on|off] log on or log off"
    echo "CLUSTERTYPE:`GetAllClusterType`"
    exit 0
elif [ "x${CMD}" = "xinfo" ]; then
    #$JSTORM_HOME/bin/jstorm-topics.sh --list --zookeeper  $JSTORM_ZOOKEEPER_CONNECT
    echo "=================================================="
    echo "jstorm-topics:"
    echo "==>$JSTORM_HOME/bin/zookeeper-shell.sh  $JSTORM_ZOOKEEPER_CONNECT ls /brokers/topics"
    $JSTORM_HOME/bin/zookeeper-shell.sh  $JSTORM_ZOOKEEPER_CONNECT ls /brokers/topics
    echo "==>$JSTORM_HOME/bin/jstorm-topics.sh --list --zookeeper $JSTORM_ZOOKEEPER_CONNECT"
    TOPICLIST=$(eval "$JSTORM_HOME/bin/jstorm-topics.sh --list --zookeeper $JSTORM_ZOOKEEPER_CONNECT|grep -v ^__")
    echo TOPICLIST="${TOPICLIST}"
    for topic in ${TOPICLIST}
    do
        echo "--------------------------------------------"
        echo "TOPIC [${topic}] Detail:"
        echo "--------------------------------------------"
        echo "==>jstorm-topics.sh --zookeeper $JSTORM_ZOOKEEPER_CONNECT --describe --topic ${topic}"
        jstorm-topics.sh --zookeeper $JSTORM_ZOOKEEPER_CONNECT --describe --topic ${topic}
    done
    echo "=================================================="
    echo "jstorm-brokers:"
    if [[ -z "$JSTORM_ADVERTISED_HOST_NAME" && -n "$HOSTNAME_COMMAND" ]]; then
        export JSTORM_ADVERTISED_HOST_NAME=$(eval $HOSTNAME_COMMAND)
    fi

    if [[ -z "$JSTORM_HOST_NAME" ]]; then
        export JSTORM_HOST_NAME=${JSTORM_ADVERTISED_HOST_NAME}
    fi

    if [[ -z "$JSTORM_ADVERTISED_HOST_NAME" ]]; then
        #export JSTORM_ADVERTISED_HOST_NAME=$(eval "ifconfig eth0|grep -w -i 'inet addr'|awk -F: '{print \$2}'|awk '{print \$1}'")
        export JSTORM_ADVERTISED_HOST_NAME=$(eval "hostname")
    fi

    if [[ -z "$JSTORM_ADVERTISED_LISTENERS" ]]; then
        export JSTORM_ADVERTISED_LISTENERS="PLAINTEXT://${JSTORM_ADVERTISED_HOST_NAME}:${JSTORM_ADVERTISED_PORT}"
        unset JSTORM_ADVERTISED_HOST_NAME
        unset JSTORM_ADVERTISED_PORT
    fi
    echo "jstorm-brokers-advertise_ip:port=${JSTORM_ADVERTISED_LISTENERS}"
    echo "jstorm-brokers-localhost_ip:port=PLAINTEXT://0.0.0.0:${JSTORM_PORT}"
    echo "jstorm-brokers-id==> $JSTORM_HOME/bin/zookeeper-shell.sh  $JSTORM_ZOOKEEPER_CONNECT ls /brokers/ids"
    
    BROKERLIST=$(eval "$JSTORM_HOME/bin/zookeeper-shell.sh  $JSTORM_ZOOKEEPER_CONNECT ls /brokers/ids|sed -n '/WatchedEvent state:/{n;p}'|awk '{print substr(\$0,2,length(\$0)-2)}'|tr ',' ' '")
    echo BROKERLIST="${BROKERLIST}"
    for broker in ${BROKERLIST}
    do
        echo "--------------------------------------------"
        echo "BROKER [${broker}] Detail:"
        echo "--------------------------------------------"
        echo "==>$JSTORM_HOME/bin/zookeeper-shell.sh  $JSTORM_ZOOKEEPER_CONNECT ls /brokers/ids/${broker}"
        $JSTORM_HOME/bin/zookeeper-shell.sh  $JSTORM_ZOOKEEPER_CONNECT ls /brokers/ids/${broker}
    done
    LOGFILE="${CLUSTERVOLUME}/`hostname`/log/server.log*"
    echo "jstorm-brokers-log==>`grep -w 'Registered broker' ${LOGFILE}`"
elif [ "x${CMD}" = "xstart" ]; then
    #nimbus.host和nimbus.host.start.supervisor为个性化配置，取消不使用，仅起停脚本使用
    logonoff $istrace
    #will be moved to $JSTORM_CONF_DIR/
    CONFIG="$JSTORM_HOME/conf/storm.yaml"
    if [ ! -f $CONFIG ]; then
        cp /dev/null $CONFIG
    fi
    if [ "x$JSTORM_CONF_DIR" = "x" ]
    then
        export JSTORM_CONF_DIR=$JSTORM_HOME/conf
    fi
    cp -f $CONFIG ${JSTORM_CONF_DIR}/ 1>/dev/null 2>/dev/null
    CONFIG="${JSTORM_CONF_DIR}/storm.yaml"
    for VAR in `env`
    do
      ismatch=`echo $VAR|awk '{if(match($0,"STORMYAML_")==0)print $0;}'`
      if [ "x$ismatch" != "x" ]; then
        continue;
      fi
      echo "ENV_VAR:$VAR"
      jstorm_name=`echo "$VAR" | sed -r "s/STORMYAML_(.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr _ .`
      env_var=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g"`
      env_val=$(eval "echo \$$env_var")
      if egrep -q "(^|^#)$jstorm_name=" $CONFIG; then
        echo "MODIFY storm.yaml==>$jstorm_name:${env_val}"
        sed -r -i "s@(^|^#)($jstorm_name):(.*)@\2:${env_val}@g" $CONFIG #note that no config values may contain an '@' char
      else
        echo "ADD INTO storm.yaml==>$jstorm_name:${env_val}"
        echo "$jstorm_name: ${env_val}" >> $CONFIG
      fi
    done
    shift
    echo "============================================"
    cat $CONFIG
    echo "============================================"
    echo "==>start jstorm ..."
    cd ${CLUSTERVOLUME}/bin&&./start.sh "$@"
    #exec "$@"
elif [ "x${CMD}" = "xstop" ]; then
    $JSTORM_HOME/bin/stop.sh
    exit 0
elif [ "x${CMD}" = "xbash" ]; then
    tail -f /etc/timezone
elif [ "x${CMD}" = "xlog" ]; then
    logonoff $istrace
else
    exec $@
fi

