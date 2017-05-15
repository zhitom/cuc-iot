# redis-cluster-mq

#概述

 redis-cluster-mq是在[https://hub.docker.com/r/grokzen/redis-cluster/](https://hub.docker.com/r/grokzen/redis-cluster/)基础之上创建的，用于一个基于redis的队列缓存集群，因此此redis集群仅考虑1个副本且关闭redis持久化功能。
 
 为了实现集群的扩展，所以将创建集群的命令配置为单独的一个镜像：cuc-iot-redis-cluster-trib-mq，这样容器部署比例可以是:

cuc-iot-redis-cluster-mq ： cuc-iot-redis-cluster-trib-mq = n  ：1

- [zhitom/cuc-iot-redis-cluster-mq](https://hub.docker.com/r/zhitom/cuc-iot-redis-cluster-mq/ "https://hub.docker.com/r/zhitom/cuc-iot-redis-cluster-mq/") is deploy redis 6 instances=3M+3S!(实例，6个实例，3主+3备)，可以无限制扩展。
- [zhitom/cuc-iot-redis-cluster-trib-mq](https://hub.docker.com/r/zhitom/cuc-iot-redis-cluster-trib-mq/ "https://hub.docker.com/r/zhitom/cuc-iot-redis-cluster-trib-mq/") revoks redis-trib.rb for create redis-cluster!(仅调用集群创建命令，执行后即销毁，需单独下载镜像，如果宿主机自带redis-trib.rb，可以不用下载此镜像)

#目录文件说明

- Makefile和Dockerfile用于创建该镜像
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

    #build redis instance image，default imagename is 
    make rebuild
    #build redis cluster image
    cd redis-cluster-trib && make build

And to start cluster use:

    # start all redis instance，default container-name is redis-cluster-mq.1
    make run
    # create redis cluster，if it is restarted,don't need to execute this:
    cd redis-cluster-trib && make run
    # if your localhost has redis-trib.rb，Please execute this：
    cd redis-cluster-trib && make clusterinfo && ./redis-cluster-trib.sh local your-trib-command

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

To need more redis instances

    # default is 1 ,now 2,another 3M+3S,container-name is redis-cluster-mq.2
    make CONTAINERID=2 run
    # now 3,another 3M+3S,container-name is redis-cluster-mq.3
    make CONTAINERID=3 run
    
    # run make to create cluster
    cd redis-cluster-trib && make CIDLIST="1 2 3" run
    # if your localhost has redis-trib.rb，Please execute this：
    cd redis-cluster-trib && make CIDLIST="1 2 3" clusterinfo && ./redis-cluster-trib.sh local your-trib-command

    # client for first redis-instance's ip port
    make cli
    # client for another
    redis-cli -c -h docker-ip -p docker-port



