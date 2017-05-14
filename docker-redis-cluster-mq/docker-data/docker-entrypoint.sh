#!/bin/sh

if [ "$1" = 'redis-cluster-mq' ]; then
    #删除mq相关的以前产生的redis集群配置
    PORTS="5000 5001 5002 5500 5501 5502"
    for port in ${PORTS}; do
      mkdir -p /redis-cluster-mq/conf/${port} /redis-cluster-mq/data/${port}
      #nodes.conf有数据信息，不能清除
      #if [ -e /redis-cluster-mq/data/${port}/nodes.conf ]; then
      #  rm /redis-cluster-mq/data/${port}/nodes.conf
      #fi
    done
    #产生mq相关的新的redis集群配置
    for port in ${PORTS}; do
      PORT=${port} envsubst < /redis-cluster-mq/conf/redis-cluster.tmpl > /redis-cluster-mq/conf/${port}/redis.conf
    done
    #下面的是普通的redis，非集群，暂不用
    #for port in 15000 15001 15002; do
    #  PORT=${port} envsubst < /redis-cluster-mq/conf/redis.tmpl > /redis-cluster-mq/conf/${port}/redis.conf
    #done

    supervisord -c /etc/supervisor/supervisord.conf
    sleep 3

    #记录当前启动的redis实例信息
    IP=`ifconfig | grep "inet addr:17" | cut -f2 -d ":" | cut -f1 -d " "`
    cp /dev/null /redis-cluster-mq/conf/redis-cluster.ports
    for port in ${PORTS}; do
      echo ${IP}:${port} >> /redis-cluster-mq/conf/redis-cluster.ports
    done
    #cp -f /dev/null /redis-cluster-mq/log/supervisor_redis_1.log
    tail -f /redis-cluster-mq/log/supervisor_redis*.log
else
  exec "$@"
fi

