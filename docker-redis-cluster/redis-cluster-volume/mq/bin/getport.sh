. `dirname $0`/common.sh

CLUSTERTYPE="$1";shift
CID="$1";shift

CheckClusterType ${CLUSTERTYPE}

if [ $? -ne 0 ]; then
  GetAllClusterType
  exit 110
fi

VOLUME="./redis-cluster-volume/${CLUSTERTYPE}"

cat ${VOLUME}/conf/supervisor-allredis.${CLUSTERTYPE}.${CID}.conf 2>/dev/null|grep 'command=/redis/src/redis-server'|awk -F/ '{printf "-p %s:%s\n",$8,$8}' > ${VOLUME}/conf/redis-cluster.ports.${CLUSTERTYPE}.${CID}.conf



