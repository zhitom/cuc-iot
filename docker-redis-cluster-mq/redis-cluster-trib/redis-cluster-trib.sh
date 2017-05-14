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
else
  exec "$@"
fi

