FROM grokzen/redis-cluster:3.2.7

MAINTAINER ZhiQiang Shan <shandyshandy@163.com>

##########################################
#系统环境问题
##########################################
#切换当前目录
WORKDIR /
ENV REDIS_HOME /redis/src
#RUN apt-get install -y vim sudo
#RUN echo export LC_ALL=C.UTF-8 >>/etc/profile

##########################################
#下面是集群个性化的配置，覆盖到镜像里边
##########################################
RUN rm -rf /redis-conf /docker-entrypoint.sh
RUN rm -rf /redis-data
RUN rm -rf /etc/supervisor/conf.d/supervisord.conf
COPY ./build-data/supervisord.conf  /etc/supervisor/supervisord.conf

##########################################
#增加可执行权限
##########################################
RUN echo "chmod 755 /redis-cluster/*/bin/*.sh" >> ~/.bash_profile

##########################################
#暴露端口给宿主机,为提高镜像可配置化，使用run的-p参数来代替
##########################################
#EXPOSE 5000 5001 5002 5500 5501 5502

##########################################
#执行脚本，并将CMD指定字符串作为脚本入参传递给docker-entrypoint.sh
##########################################
ENTRYPOINT ["/redis-cluster/mq/bin/docker-entrypoint.sh"]
CMD ["mq","1"]


