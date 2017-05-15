FROM grokzen/redis-cluster:3.2.7

MAINTAINER ZhiQiang Shan <shandyshandy@163.com>

##########################################
#系统环境问题
##########################################
#切换当前目录
WORKDIR /
#RUN apt-get install -y vim sudo
#RUN echo export LC_ALL=C.UTF-8 >>/etc/profile

##########################################
#下面是集群个性化的配置，覆盖到镜像里边
##########################################
RUN rm -rf /redis-conf /docker-entrypoint.sh
RUN rm -rf /redis-data
RUN mkdir -p /redis-cluster-mq/conf

##########################################
#redis配置文件
##########################################
#COPY ./docker-data/redis.tmpl                  /redis-cluster-mq/conf/redis.tmpl
COPY ./docker-data/redis-cluster.tmpl           /redis-cluster-mq/conf/redis-cluster.tmpl
COPY ./docker-data/redis-cluster-common.conf    /redis-cluster-mq/conf/redis-cluster-common.conf

#redis集群配置文件
COPY ./docker-data/redis-cluster.ports.all      /redis-cluster-mq/conf/redis-cluster.ports.all
COPY ./docker-data/redis-cluster.replicas       /redis-cluster-mq/conf/redis-cluster.replicas

# Add supervisord configuration，用于监控进程状态
COPY ./docker-data/supervisord.conf             /etc/supervisor/conf.d/supervisord.conf

# Add startup script，1.输出实例信息；2.客户端脚本；3.用于创建集群（只须调用一次）
COPY ./docker-data/docker-entrypoint.sh         /redis-cluster-mq/docker-entrypoint.sh
COPY ./docker-data/redis-cli.sh                 /redis-cli.sh
COPY ./docker-data/redis-cluster-trib.sh        /redis-cluster-mq/redis-cluster-trib.sh

##########################################
#增加可执行权限
##########################################
RUN chmod 755 /redis-cluster-mq/docker-entrypoint.sh
RUN chmod 755 /redis-cli.sh
RUN chmod 755 /redis-cluster-mq/redis-cluster-trib.sh

##########################################
#暴露端口给宿主机
##########################################
EXPOSE 5000 5001 5002 5500 5501 5502

##########################################
#执行脚本，并将CMD指定字符串作为脚本入参传递给docker-entrypoint.sh
##########################################
ENTRYPOINT ["/redis-cluster-mq/docker-entrypoint.sh"]
CMD ["redis-cluster-mq"]


