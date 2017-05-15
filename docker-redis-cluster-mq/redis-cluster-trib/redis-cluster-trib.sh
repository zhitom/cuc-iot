#!/bin/sh
set -x
if [ "$1" = 'redis-cluster-mq' ]; then
    #获取整个集群的实例信息，可能是跨容器的集群
    REPNUM=`cat /redis-cluster-mq/conf/redis-cluster.replicas`
    PORTSLIST=""
    for port in `cat /redis-cluster-mq/conf/redis-cluster.ports.all`; do
      PORTSLIST="${PORTSLIST} ${port}"
    done
    #检测集群状态是否正常
    FIRSTPORT=`cat /redis-cluster-mq/conf/redis-cluster.ports.all|head -1`
    msg="`/redis/src/redis-trib.rb check ${FIRSTPORT}|grep '\[ERR\]'`"
    if [ "x${msg}" != "x" ]; then
      echo "ruby /redis/src/redis-trib.rb create --replicas ${REPNUM} ${PORTSLIST}"
      echo "yes" | ruby /redis/src/redis-trib.rb create --replicas ${REPNUM} ${PORTSLIST}
      msg="`/redis/src/redis-trib.rb check ${FIRSTPORT}|grep '\[ERR\]'`"
      if [ "x${msg}" != "x" ]; then
        echo "create cluster FAILED!"
      fi
    else
      echo "redis-cluster maybe is ok,please check it again!"
    fi
    #tail -f /var/log/bootstrap.log
elif [ "$1" = 'local' ]; then
    if [ "x$2" = 'x' ]; then
        echo "Please use your redis-trib.rb command!"
        exit 100
    fi
    #获取整个集群的实例信息，可能是跨容器的集群
    REPNUM=`cat ./redis-cluster.replicas`
    PORTSLIST=""
    for port in `cat ./redis-cluster.ports.all`; do
      PORTSLIST="${PORTSLIST} ${port}"
    done
    #检测集群状态是否正常
    FIRSTPORT=`cat ./redis-cluster.ports.all|head -1`
    msg="`$2 check ${FIRSTPORT}|grep '\[ERR\]'`"
    if [ "x${msg}" != "x" ]; then
      echo "ruby $2 create --replicas ${REPNUM} ${PORTSLIST}"
      echo "yes" | ruby $2 create --replicas ${REPNUM} ${PORTSLIST}
      msg="`$2 check ${FIRSTPORT}|grep '\[ERR\]'`"
      if [ "x${msg}" != "x" ]; then
        echo "create cluster FAILED!"
      fi
    else
      echo "redis-cluster maybe is ok,please check it again!"
    fi
else
  exec "$@"
fi

