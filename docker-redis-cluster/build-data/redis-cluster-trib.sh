#!/bin/sh
#set -x
. `dirname $0`/common.sh

REDISTYPE="$1"

CheckRedisType ${REDISTYPE}

isredistype=0
if [ $? -ne 0 ]; then
  if [ "x$1" = "xcheck" ]; then
    :
  elif [ "x$1" = "xlocal" ]; then
    :
  elif [ "x$1" = "xsave" ]; then
    :
  elif [ "x$1" = "xclear" ]; then
    :
  else
    echo `GetAllRedisType` or check local save clear
    exec "$@"
    exit 111
  fi
else
  isredistype=1
fi

REDISVOLUME="/redis-cluster/${REDISTYPE}"
VOLUMENAME="redis-cluster-volume"
LOCALVOLUME="/${VOLUMENAME}/${REDISTYPE}"
LOGFILE=${REDISVOLUME}/log/`basename $0`.log
REDISPATH="${REDIS_HOME}"  #/redis/src

if [ $isredistype -eq 1 ]; then
    #获取整个集群的实例信息，可能是跨容器的集群
    REPNUM=`cat ${REDISVOLUME}/conf/redis-cluster.replicas 2>/dev/null`
    PORTSLIST=""
    for port in `cat ${REDISVOLUME}/data/redis-cluster.ip.port.all 2>/dev/null`; do
      PORTSLIST="${PORTSLIST} ${port}"
    done
    #检测集群状态是否正常
    FIRSTPORT=`cat ${REDISVOLUME}/data/redis-cluster.ip.port.all 2>/dev/null|head -1`
    msg="`${REDISPATH}/redis-trib.rb check ${FIRSTPORT}|grep '\[ERR\]'`"
    if [ "x${msg}" != "x" ]; then
      echo "ruby ${REDISPATH}/redis-trib.rb create --replicas ${REPNUM} ${PORTSLIST}" >> ${LOGFILE}
      echo "yes" | ruby ${REDISPATH}/redis-trib.rb create --replicas ${REPNUM} ${PORTSLIST} >> ${LOGFILE}
      msg="`${REDISPATH}/redis-trib.rb check ${FIRSTPORT}|grep '\[ERR\]'`"
      if [ "x${msg}" != "x" ]; then
        echo "create cluster FAILED!" >> ${LOGFILE}
      fi
    else
      echo "redis-cluster maybe is ok,please check it again!" >> ${LOGFILE}
    fi
    #tail -f /var/log/bootstrap.log
elif [ "$1" = 'check' ]; then
    #获取整个集群的实例信息，可能是跨容器的集群
    REPNUM=`cat ${REDISVOLUME}/conf/redis-cluster.replicas 2>/dev/null`
    PORTSLIST=""
    for port in `cat ${REDISVOLUME}/data/redis-cluster.ip.port.all 2>/dev/null`; do
      PORTSLIST="${PORTSLIST} ${port}"
    done
    #检测集群状态是否正常
    FIRSTPORT=`cat ${REDISVOLUME}/data/redis-cluster.ip.port.all 2>/dev/null|head -1`
    msg="`${REDISPATH}/redis-trib.rb check ${FIRSTPORT}|grep '\[ERR\]'`"
    if [ "x${msg}" = "x" ]; then
      echo "redis-cluster maybe is ok,please check it again!" >> ${LOGFILE}
    else
      echo "redis-cluster maybe is not created,please check it again!" >> ${LOGFILE}
    fi
elif [ "$1" = 'local' ]; then
    if [ "x$2" = 'x' ]; then
        echo "Please use your redis-trib.rb command!" >> ${LOGFILE}
        exit 100
    fi
    #获取整个集群的实例信息，可能是跨容器的集群
    REPNUM=`cat ${LOCALVOLUME}/conf/redis-cluster.replicas 2>/dev/null`
    PORTSLIST=""
    for port in `cat ${LOCALVOLUME}/data/redis-cluster.ip.port.all 2>/dev/null`; do
      PORTSLIST="${PORTSLIST} ${port}"
    done
    #检测集群状态是否正常
    FIRSTPORT=`cat ${LOCALVOLUME}/data/redis-cluster.ip.port.all 2>/dev/null|head -1`
    msg="`$2 check ${FIRSTPORT}|grep '\[ERR\]'`"
    if [ "x${msg}" != "x" ]; then
      echo "ruby $2 create --replicas ${REPNUM} ${PORTSLIST}" >> ${LOGFILE}
      echo "yes" | ruby $2 create --replicas ${REPNUM} ${PORTSLIST} >> ${LOGFILE}
      msg="`$2 check ${FIRSTPORT}|grep '\[ERR\]'`"
      if [ "x${msg}" != "x" ]; then
        echo "create cluster FAILED!" >> ${LOGFILE}
      fi
    else
      echo "redis-cluster maybe is ok,please check it again!" >> ${LOGFILE}
    fi
elif [ "$1" = 'save' ]; then
    FIRSTPORT=`cat ./docker-data/redis-cluster.ip.port.all 2>/dev/null|head -1`
    IP=`echo $FIRSTPORT|awk -F: '{print $1}'`
    PORT=`echo $FIRSTPORT|awk -F: '{print $2}'`
    REDIS_SELF ${REDISPATH}/redis-cli "-c -h ${IP} -p ${PORT}" "CLUSTER SAVECONFIG"
    echo ${2} >> ${REDISVOLUME}/conf/redis-cluster.ip.port.all
elif [ "$1" = 'clear' ]; then #clear 
  echo "Clear ${REDISVOLUME}/conf/redis-cluster.ip.port.all" >> ${LOGFILE}
  cp /dev/null ${REDISVOLUME}/conf/redis-cluster.ip.port.all
  #tail -f /var/log/bootstrap.log #容器不退出
fi

