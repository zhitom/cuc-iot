. `dirname $0`/common.sh

ISLIST="$1";shift
REDISTYPE="$1";shift

CheckRedisType ${REDISTYPE}

if [ $? -ne 0 ]; then
  GetAllRedisType
  exit 110
fi

REDISVOLUME="/redis-cluster/${REDISTYPE}"
REDISPATH="${REDIS_HOME}"  #/redis/src

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
        ${REDISPATH}/redis-cli -c -h ${ip} -p ${port} info 2>/dev/null 1>/dev/null
        if [ $? -ne 0 ]; then
            echo "[DOWN] ${REDISPATH}/redis-cli -c -h ${ip} -p ${port}"
            continue;
        fi
        FIRSTIP=${ip}
        FIRSTP=${port}
        echo "[ACTIVE] ${REDISPATH}/redis-cli -c -h ${ip} -p ${port}"
    done
    echo "==========================================================================="
    ${REDISPATH}/redis-cli -c -h ${FIRSTIP} -p ${FIRSTP} cluster info
else
    cat ${REDISVOLUME}/data/redis-cluster.ip.port.all 2>/dev/null|while read ipport
    do
        if [ "x${ipport}" = "x" ]; then
            continue;
        fi
        ip=`echo ${ipport}|awk -F: '{print $1}'`
        port=`echo ${ipport}|awk -F: '{print $2}'`
        ${REDISPATH}/redis-cli -c -h ${ip} -p ${port} info 2>/dev/null 1>/dev/null
        if [ $? -ne 0 ]; then
            echo "[DOWN] ${REDISPATH}/redis-cli -c -h ${ip} -p ${port}"
            continue;
        fi
        FIRSTIP=${ip}
        FIRSTP=${port}
        echo "==========================================================================="
        echo "==>${REDISPATH}/redis-cli -c -h ${FIRSTIP} -p ${FIRSTP}" $@
        ${REDISPATH}/redis-cli -c -h ${FIRSTIP} -p ${FIRSTP} $@
    done
    exit 0
fi
echo "${REDISPATH}/redis-cli -c -h ${FIRSTIP} -p ${FIRSTP}" $@
exec ${REDISPATH}/redis-cli -c -h ${FIRSTIP} -p ${FIRSTP} $@
#cat ${REDISVOLUME}/data/redis-cluster.ip.port.all 2>/dev/null|while read ipport
#do
#    if [ "x${ipport}" = "x" ]; then
#        continue;
#    fi
#    ip=`echo ${ipport}|awk -F: '{print $1}'`
#    port=`echo ${ipport}|awk -F: '{print $2}'`
#    ${REDISPATH}/redis-cli -c -h ${ip} -p ${port} info
#    if [ $? -ne 0 ]; then
#        echo "[DOWN]${REDISPATH}/redis-cli -c -h ${ip} -p ${port}"
#        continue;
#    fi
#    echo "${REDISPATH}/redis-cli -c -h ${ip} -p ${port}" $@
#    exec ${REDISPATH}/redis-cli -c -h ${ip} -p ${port} $@
#    break;
#done



