# redis-cluster-mq

redis-cluster-mq是在[https://hub.docker.com/r/grokzen/redis-cluster/](https://hub.docker.com/r/grokzen/redis-cluster/)基础之上创建的，用于一个基于redis的队列缓存集群，Makefile和Dockerfile用于创建该镜像

- zhitom/cuc-iot-redis-cluster-mq is deploy redis 6 instances=3M+3S!(实例，6个实例，3主+3备)
- zhitom/cuc-iot-redis-cluster-trib-mq revoks redis-trib.rb for create redis-cluster!(仅调用集群创建命令，需单独下载镜像)

#目录文件说明

- docker-data：源码目录，用于创建该镜像
  - docker-entrypoint.sh：启动左右节点
  - redis-cli.sh：集群客户端封装，可选
  - redis-cluster.tmpl： 集群个性化配置模版
  - redis-cluster-common.conf：集群公共部分配置
  - supervisord.conf：实例进程监控配置，如自动自动
- redis-cluster-trib：为集群redis-trib.rb脚本运行的镜像，需单独创建该镜像并执行，在所有的redis实例启动完毕后需执行该容器才能使集群生效。
  - redis-cli.sh：集群客户端封装，可选，等同上面的redis-cli.sh
  - redis-cluster.ports.all：所有redis实例的ip和port列表，从实例中自动采集产生，需在Makefile里边配置完整
  - redis-cluster.replicas：集群的副本数，不含主节点
  - redis-cluster-trib.sh：集群启动脚本
- redis-cluster-volume：为容器共享的文件夹，子目录为log和data，存放日志和数据文件

#操作统一

为简化和统一操作，使用make命令来进行了封装：

make的目标如下：

    - rebuild   rebuild image
    - run       run image to new container
    - start     start container
    - stop      stop container
    - bash      start bash with current container
    - cli       start redis-cli using first redis-ip:port instance container
    - clean     delete container
    - distclean delete image

# 版本

- latest == 3.2.7

# 操作方法

To build your own image run,一般执行一次即可:

    #build redis instance image
    make rebuild
    #build redis cluster image
    cd redis-cluster-trib && make build

And to run the container use:

    # start all redis instance
    make run
    # create redis cluster，if it is restarted,don't need to execute this:
    cd redis-cluster-trib && make run

    # and top stop the container run
    make stop
    # and restart the container
    make start
    # and start with bash
    make bash

To connect to your cluster you can use the redis-cli tool:

    make cli

To shutdown cluster

    # first save cluster infomations
     172.17.0.2:5000> CLUSTER SAVECONFIG
    # then stop container
     make stop

To Restart cluster
    
    make run


