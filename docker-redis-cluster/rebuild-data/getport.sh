. `dirname $0`/common.sh

REDISTYPE="$1";shift
CID="$1";shift

CheckRedisType ${REDISTYPE}

VOLUME="./redis-cluster-volume/${REDISTYPE}"

cat ${VOLUME}/conf/supervisor-allredis.${REDISTYPE}.${CID}.conf 2>/dev/null|grep 'command=/redis/src/redis-server'|awk -F/ '{printf "-p %s:%s\n",$8,$8}' > ${VOLUME}/conf/redis-cluster.ports.${REDISTYPE}.${CID}.conf



