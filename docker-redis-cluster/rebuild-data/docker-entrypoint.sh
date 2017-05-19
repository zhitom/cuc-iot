#!/bin/sh
#set -x
. `dirname $0`/common.sh

REDISTYPE="$1";shift
CheckRedisType "${REDISTYPE}"

if [ $? -ne 0 ]; then
  GetAllRedisType
  exit 110
fi

CID="$1";shift
REDISVOLUME="/redis-cluster/${REDISTYPE}"
LOGFILE=${REDISVOLUME}/log/`basename $0`.log
#PORTS="5000 5001 5002 5500 5501 5502"
PORTS="`cat ${REDISVOLUME}/conf/redis-cluster.ports.${REDISTYPE}.${CID}.conf|awk -F: '{print $2}'`"

#删除mq相关的以前产生的redis集群配置,产生mq相关的新的redis集群配置
for port in ${PORTS}; do
  mkdir -p ${REDISVOLUME}/data/${port}
  PORT=${port} envsubst < ${REDISVOLUME}/conf/redis-cluster.tmpl > ${REDISVOLUME}/data/${port}/redis.conf
  #nodes.conf有数据信息，不能清除
  #if [ -e /redis-cluster-mq/data/${port}/nodes.conf ]; then
  #  rm /redis-cluster-mq/data/${port}/nodes.conf
  #fi
done
#下面的是普通的redis，非集群，暂不用
#for port in 15000 15001 15002; do
#  PORT=${port} envsubst < ${REDISVOLUME}/conf/redis.tmpl > ${REDISVOLUME}/data/${port}/redis.conf
#done

mv /etc/supervisor/supervisord.conf /etc/supervisor/supervisord.conf.orig
sed 's/REDISTYPE/'${REDISTYPE}'/g' /etc/supervisor/supervisord.conf.orig|sed 's/CONTAINERID/'${CID}'/g' > /etc/supervisor/supervisord.conf
supervisord -c /etc/supervisor/supervisord.conf
sleep 3

#记录当前启动的redis实例信息
docker0=`ifconfig|grep ^docker`
IP="127.0.0.1"
if [ "x${docker0}" != "x" ]; then #host
  IP=`ifconfig | grep "inet addr:19" | cut -f2 -d ":" | cut -f1 -d " "`
else #bridger
  IP=`ifconfig | grep "inet addr:17" | cut -f2 -d ":" | cut -f1 -d " "`
fi

for port in ${PORTS}; do
  echo ${IP}:${port} > ${REDISVOLUME}/data/${port}/redis-cluster.ip.port
done
#cp -f /dev/null ${REDISVOLUME}/log/supervisor_redis_1.log
tail -f ${REDISVOLUME}/log/redis-cluster-trib.sh.log ${REDISVOLUME}/log/supervisor*.log


