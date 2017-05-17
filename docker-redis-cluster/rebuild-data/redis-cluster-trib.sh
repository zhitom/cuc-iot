#!/bin/sh
#set -x
. `dirname $0`/common.sh

REDISTYPE="$1"

CheckRedisType ${REDISTYPE}

REDISVOLUME="/redis-cluster/${REDISTYPE}"
VOLUMENAME="redis-cluster-volume"
LOCALVOLUME="/${VOLUMENAME}/${REDISTYPE}"
LOGFILE=${REDISVOLUME}/log/`basename $0`.log

if [ "$1" = 'mq' ]; then
    #获取整个集群的实例信息，可能是跨容器的集群
    REPNUM=`cat ${REDISVOLUME}/conf/redis-cluster.replicas 2>/dev/null`
    PORTSLIST=""
    for port in `cat ${REDISVOLUME}/data/redis-cluster.ip.port.all 2>/dev/null`; do
      PORTSLIST="${PORTSLIST} ${port}"
    done
    #检测集群状态是否正常
    FIRSTPORT=`cat ${REDISVOLUME}/data/redis-cluster.ip.port.all 2>/dev/null|head -1`
    msg="`/redis/src/redis-trib.rb check ${FIRSTPORT}|grep '\[ERR\]'`"
    if [ "x${msg}" != "x" ]; then
      echo "ruby /redis/src/redis-trib.rb create --replicas ${REPNUM} ${PORTSLIST}" >> ${LOGFILE}
      echo "yes" | ruby /redis/src/redis-trib.rb create --replicas ${REPNUM} ${PORTSLIST} >> ${LOGFILE}
      msg="`/redis/src/redis-trib.rb check ${FIRSTPORT}|grep '\[ERR\]'`"
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
    msg="`/redis/src/redis-trib.rb check ${FIRSTPORT}|grep '\[ERR\]'`"
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
    REDIS_SELF "-c -h ${IP} -p ${PORT}" "CLUSTER SAVECONFIG"
    echo ${2} >> /redis-cluster/mq/conf/redis-cluster.ip.port.all
else #clear 
  echo "Clear /redis-cluster/mq/conf/redis-cluster.ip.port.all" >> ${LOGFILE}
  cp /dev/null /redis-cluster/mq/conf/redis-cluster.ip.port.all
  #tail -f /var/log/bootstrap.log #容器不退出
fi

