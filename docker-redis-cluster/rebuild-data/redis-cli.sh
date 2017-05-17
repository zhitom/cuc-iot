. `dirname $0`/common.sh

REDISTYPE="$1";shift

CheckRedisType ${REDISTYPE}

REDISVOLUME="/redis-cluster/${REDISTYPE}"

FIRSTPORT=`cat ${REDISVOLUME}/data/redis-cluster.ip.port.all 2>/dev/null|head -1`
FIRSTIP=`echo ${FIRSTPORT}|awk -F: '{print $1}'`
FIRSTP=`echo ${FIRSTPORT}|awk -F: '{print $2}'`

echo "Redis Instances:"
echo "=================================================="
cat ${REDISVOLUME}/data/redis-cluster.ip.port.all 2>/dev/null|while read ipport
do
    if [ "x${ipport}" = "x" ]; then
        continue;
    fi
    ip=`echo ${ipport}|awk -F: '{print $1}'`
    port=`echo ${ipport}|awk -F: '{print $2}'`
    echo "/redis/src/redis-cli -c -h ${ip} -p ${port}"
done
echo "=================================================="
echo "/redis/src/redis-cli -c -h ${FIRSTIP} -p ${FIRSTP}" $@
exec /redis/src/redis-cli -c -h ${FIRSTIP} -p ${FIRSTP} $@


