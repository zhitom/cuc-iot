FROM grokzen/redis-cluster:3.2.7

MAINTAINER ZhiQiang Shan <shandyshandy@163.com>

##########################################
#系统环境问题
##########################################
#切换当前目录
WORKDIR /
#RUN apt-get install -y vim sudo

##########################################
#下面是集群个性化的配置，覆盖到镜像里边
##########################################
RUN rm -rf      /redis-conf     /docker-entrypoint.sh
RUN rm -rf      /redis-data
RUN mkdir -p    /redis-cluster-mq/conf
#redis配置文件
COPY ./redis-cluster.ports.all      /redis-cluster-mq/conf/redis-cluster.ports.all
COPY ./redis-cluster.replicas       /redis-cluster-mq/conf/redis-cluster.replicas
COPY ./redis-cli.sh                 /redis-cli.sh

##########################################
# Add startup script，用于启动集群
##########################################
COPY ./redis-cluster-trib.sh /redis-cluster-mq/redis-cluster-trib.sh

##########################################
#增加可执行权限
##########################################
RUN chmod 755 /redis-cluster-mq/redis-cluster-trib.sh
RUN chmod 755 /redis-cli.sh

##########################################
#执行脚本，并将CMD指定字符串作为脚本入参传递给docker-entrypoint.sh
##########################################
ENTRYPOINT ["/redis-cluster-mq/redis-cluster-trib.sh"]
CMD ["redis-cluster-mq"]


