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

#处理目录
if [ ! -f ${STORMYAML_storm_local_dir} ]; then
    mkdir -p ${STORMYAML_storm_local_dir}
fi
if [ ! -f ${STORMYAML_STORM_LOCAL_DIR} ]; then
    mkdir -p ${STORMYAML_STORM_LOCAL_DIR}
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

killJStorm()
{
    ps -ef|grep $1|grep -v grep |awk '{print $2}' |xargs kill 2>/dev/null
    if [ $? -ne 0 ]; then
        ps -ef|grep $1
        return;
    fi
    sleep 3
    ps -ef|grep $1
    echo "kill "$1
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
    echo "Unsupported Now!"
    exit 0
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
    #$JSTORM_HOME/bin/stop.sh
    killJStorm "Supervisor"
    killJStorm "NimbusServer"
    echo "Successfully stop jstorm"
    exit 0
elif [ "x${CMD}" = "xbash" ]; then
    tail -f /etc/timezone
elif [ "x${CMD}" = "xlog" ]; then
    logonoff $istrace
else
    exec $@
fi

