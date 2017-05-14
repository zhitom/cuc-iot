FIRSTPORT=`cat /redis-cluster-mq/conf/redis-cluster.ports.all /redis-cluster-mq/conf/redis-cluster.ports 2>/dev/null|head -1`
FIRSTIP=`echo ${FIRSTPORT}|awk -F: '{print $1}'`
FIRSTP=`echo ${FIRSTPORT}|awk -F: '{print $2}'`
echo "IP:PORT LIST:"
cat /redis-cluster-mq/conf/redis-cluster.ports.all /redis-cluster-mq/conf/redis-cluster.ports 2>/dev/null|while read ipport
do
    ip=`echo ${ipport}|awk -F: '{print $1}'`
    port=`echo ${ipport}|awk -F: '{print $2}'`
    echo "/redis/src/redis-cli -c -h ${ip} -p ${port}"
done
echo "/redis/src/redis-cli -c -h ${FIRSTIP} -p ${FIRSTP}"
exec /redis/src/redis-cli -c -h ${FIRSTIP} -p ${FIRSTP} $@


