#!/bin/sh
#set -x
. `dirname $0`/common.sh

CLUSTERTYPE="$1";shift
CheckClusterType "${CLUSTERTYPE}"

if [ $? -ne 0 ]; then
  GetAllClusterType
  exit 110
fi

CID="$1";shift
CLUSTERVOLUME="/redis-cluster/${CLUSTERTYPE}"
LOGFILE=${CLUSTERVOLUME}/log/`basename $0`.log
#PORTS="5000 5001 5002 5500 5501 5502"
PORTS="`cat ${CLUSTERVOLUME}/conf/redis-cluster.ports.${CLUSTERTYPE}.${CID}.conf|awk -F: '{print $2}'`"

#删除mq相关的以前产生的redis集群配置,产生mq相关的新的redis集群配置
for port in ${PORTS}; do
  mkdir -p ${CLUSTERVOLUME}/data/${port}
  PORT=${port} envsubst < ${CLUSTERVOLUME}/conf/redis-cluster.tmpl > ${CLUSTERVOLUME}/data/${port}/redis.conf
  #nodes.conf有数据信息，不能清除
  #if [ -e /redis-cluster-mq/data/${port}/nodes.conf ]; then
  #  rm /redis-cluster-mq/data/${port}/nodes.conf
  #fi
done
#下面的是普通的redis，非集群，暂不用
#for port in 15000 15001 15002; do
#  PORT=${port} envsubst < ${CLUSTERVOLUME}/conf/redis.tmpl > ${CLUSTERVOLUME}/data/${port}/redis.conf
#done

mv /etc/supervisor/supervisord.conf /etc/supervisor/supervisord.conf.orig
sed 's/CLUSTERTYPE/'${CLUSTERTYPE}'/g' /etc/supervisor/supervisord.conf.orig|sed 's/CONTAINERID/'${CID}'/g' > /etc/supervisor/supervisord.conf
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
  echo ${IP}:${port} > ${CLUSTERVOLUME}/data/${port}/redis-cluster.ip.port
done
#cp -f /dev/null ${CLUSTERVOLUME}/log/supervisor_redis_1.log
tail -f ${CLUSTERVOLUME}/log/redis-cluster-trib.sh.log ${CLUSTERVOLUME}/log/supervisor*.log


