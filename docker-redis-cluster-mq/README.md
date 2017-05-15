# redis-cluster-mq

# 概述

 redis-cluster-mq是在[https://hub.docker.com/r/grokzen/redis-cluster/](https://hub.docker.com/r/grokzen/redis-cluster/)基础之上创建的，用于一个基于redis的队列缓存集群，因此此redis集群仅考虑1个redis副本且关闭redis持久化功能。

- container deploys redis 6 instances=3M+3S!(实例，6个实例，3主+3备)。


# 版本

- latest == 3.2.7

# Windows7 or Windows10

由于windows下面使用了boot2docker.iso,所以需先打开VirtualBox，设置一下此虚拟机：

- 设置目录共享redis-cluster-volume为redis-cluster-volume，路径为/redis-cluster-volume
- 本机是指该虚拟机，非windows系统，所以
    - 本地IP为的虚拟机IP，一般是192.168.99.100，具体需看VirtualBox的配置
    - 端口映射到的是虚拟机上面的端口
    - ssh登录：user=docker，password=tcuser
    - 由于是集群，查询key的时候会切换ip:port，所以要将容器的网络作为host模式启动
        - 此选项在Makefile.HOSTOPT设置为‘--net=host’，如果本机为linux的就设置为空即可

# 持久化

根据windows或linux的不同，需修改Makefile.WINVOLUMEPATH和VOLUMENAME路径信息：

- windows
    - WINVOLUMEPATH：mingw下的路径，使mingw下的make命令可以访问
    - VOLUMENAME：为虚拟机里边的路径，需要先在VirtualBox加载目录
- Linux
    - WINVOLUMEPATH：持久化用的目录路径
    - VOLUMENAME：等同 WINVOLUMEPATH

# 目录文件说明

- Makefile和Dockerfile用于创建该镜像
- docker-data：源码目录，用于创建该镜像
  - docker-entrypoint.sh：启动redis实例
  - redis-cli.sh：集群客户端封装，可选
  - redis-cluster.tmpl： 集群个性化配置模版
  - redis-cluster-common.conf：集群公共部分配置
  - supervisord.conf：实例进程监控配置，如自动启动
  - redis-cluster.ports.all：所有redis实例的ip和port列表，makefile自动维护
  - redis-cluster.replicas：集群的副本数，不含主节点，当前配置为1
  - redis-cluster-trib.sh：集群创建脚本
- redis-cluster-volume：为容器持久化和共享的文件夹，子目录为log和data，存放日志和数据文件

# 操作统一

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
    - cluster   	create or check cluster,only once!

# 操作方法

To build your own image run,一般执行一次即可:

    # build redis instance image，default imagename is 
    make distclean rebuild

And to start cluster use:

    # start all redis instance，default container-name is redis-cluster-mq.1
    make run
    # create redis cluster，if it is only restarted,don't need execute this:
    make cluster
    # if your localhost has redis-trib.rb，Please execute this：
    make clusterinfo && ./docker-data/redis-cluster-trib.sh local your-trib-fullname

    # and top stop the container run
    make stop
    # and restart the container
    make start
    # and start with bash
    make bash
    # delete container
    make clean

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
    make CIDLIST="1 2 3" cluster
    # if your localhost has redis-trib.rb，Please execute this：
    make CIDLIST="1 2 3" clusterinfo && ./docker-data/redis-cluster-trib.sh local your-trib-fullname

    # client for first redis-instance's ip port
    make cli
    # client for another
    redis-cli -c -h docker-ip -p docker-port


