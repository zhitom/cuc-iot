. `dirname $0`/common.sh

ISLIST="$1";shift
REDISTYPE="$1";shift

CheckRedisType ${REDISTYPE}

if [ $? -ne 0 ]; then
  GetAllRedisType
  exit 110
fi

REDISVOLUME="/redis-cluster/${REDISTYPE}"

FIRSTPORT=`cat ${REDISVOLUME}/data/redis-cluster.ip.port.all 2>/dev/null|head -1`
FIRSTIP=`echo ${FIRSTPORT}|awk -F: '{print $1}'`
FIRSTP=`echo ${FIRSTPORT}|awk -F: '{print $2}'`

if [ ${ISLIST} -eq 1 ]; then
    echo "==========================================================================="
    echo "Redis Instances:"
    cat ${REDISVOLUME}/data/redis-cluster.ip.port.all 2>/dev/null|while read ipport
    do
        if [ "x${ipport}" = "x" ]; then
            continue;
        fi
        ip=`echo ${ipport}|awk -F: '{print $1}'`
        port=`echo ${ipport}|awk -F: '{print $2}'`
        /redis/src/redis-cli -c -h ${ip} -p ${port} info 2>/dev/null 1>/dev/null
        if [ $? -ne 0 ]; then
            echo "[DOWN] /redis/src/redis-cli -c -h ${ip} -p ${port}"
            continue;
        fi
        FIRSTIP=${ip}
        FIRSTP=${port}
        echo "[ACTIVE] /redis/src/redis-cli -c -h ${ip} -p ${port}"
    done
    echo "==========================================================================="
    /redis/src/redis-cli -c -h ${FIRSTIP} -p ${FIRSTP} cluster info
else
    cat ${REDISVOLUME}/data/redis-cluster.ip.port.all 2>/dev/null|while read ipport
    do
        if [ "x${ipport}" = "x" ]; then
            continue;
        fi
        ip=`echo ${ipport}|awk -F: '{print $1}'`
        port=`echo ${ipport}|awk -F: '{print $2}'`
        /redis/src/redis-cli -c -h ${ip} -p ${port} info 2>/dev/null 1>/dev/null
        if [ $? -ne 0 ]; then
            echo "[DOWN] /redis/src/redis-cli -c -h ${ip} -p ${port}"
            continue;
        fi
        FIRSTIP=${ip}
        FIRSTP=${port}
        echo "==========================================================================="
        echo "==>/redis/src/redis-cli -c -h ${FIRSTIP} -p ${FIRSTP}" $@
        /redis/src/redis-cli -c -h ${FIRSTIP} -p ${FIRSTP} $@
    done
    exit 0
fi
echo "/redis/src/redis-cli -c -h ${FIRSTIP} -p ${FIRSTP}" $@
exec /redis/src/redis-cli -c -h ${FIRSTIP} -p ${FIRSTP} $@
#cat ${REDISVOLUME}/data/redis-cluster.ip.port.all 2>/dev/null|while read ipport
#do
#    if [ "x${ipport}" = "x" ]; then
#        continue;
#    fi
#    ip=`echo ${ipport}|awk -F: '{print $1}'`
#    port=`echo ${ipport}|awk -F: '{print $2}'`
#    /redis/src/redis-cli -c -h ${ip} -p ${port} info
#    if [ $? -ne 0 ]; then
#        echo "[DOWN]/redis/src/redis-cli -c -h ${ip} -p ${port}"
#        continue;
#    fi
#    echo "/redis/src/redis-cli -c -h ${ip} -p ${port}" $@
#    exec /redis/src/redis-cli -c -h ${ip} -p ${port} $@
#    break;
#done



