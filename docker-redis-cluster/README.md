# redis-cluster

# 概述

 redis-cluster是在[https://hub.docker.com/r/grokzen/redis-cluster/](https://hub.docker.com/r/grokzen/redis-cluster/)基础之上创建的，默认用于一个基于redis的队列缓存集群，因此此redis集群仅考虑1个redis副本且关闭redis持久化功能。

- container deploys redis 6 instances=3M+3S!(实例，6个实例，3主+3备)。
- 目前预先配置6个mdb+1个mq集群: mq devinfo session rating ratingcdr dupcheck autorule


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
        - 否则只能在容器里边使用客户端查询

# 持久化

根据windows或linux的不同，需修改Makefile.WINVOLUMEPATH和VOLUMENAME路径信息：

- windows
    - VOLUMEFULLNAME：为虚拟机里边的路径，需要先在VirtualBox加载目录
- Linux
    - VOLUMEFULLNAME：为虚拟机里边的路径

# 目录文件说明

- Makefile和Dockerfile用于创建该镜像
- rebuild-data：源码目录，用于创建该镜像
  - supervisord.conf：实例进程监控主配置文件
  - common.sh：公共函数
  - docker-entrypoint.sh：启动redis实例
  - redis-cli.sh：集群客户端封装，可选
  - redis-cluster-trib.sh：集群创建脚本
  - getport.sh：获取容器对应的端口信息，此信息在容器启动的时候输出
- redis-cluster-volume：为容器持久化和共享的文件夹
  - bin：存放可执行脚本，同rebuild-data下面的*.sh,创建镜像时makefile里边自动同步
  - conf：存放配置及模版文件
      - redis-cluster.ports.all：所有redis实例的port列表
      - redis-cluster.ports.*.*：redis实例的按主机分布的port列表
      - redis-cluster.replicas：集群的副本数，不含主节点，当前配置为1
      - redis-cluster.tmpl： 集群个性化配置模版
      - redis-cluster-common.conf：集群公共部分配置
      - supervisor-allredis.cids：容器ID列表，用于匹配supervisor-allredis.*.conf
      - supervisor-allredis.\*.conf：实例进程监控配置，如自动启动，并根据此文件名推算出容器个数，所以请只存放实际需要的配置文件，并且必须是supervisor-allredis.*.conf格式
  - data：存放redis持久化的文件
      - redis-cluster.ip.port.all：所有redis实例的IP和PORT列表，makefile自动维护，从${port}/redis-cluster.ip.port中合并
      - ${port}/redis-cluster.ip.port:容器启动的时候自动产生，汇报IP和PORT信息
      - ${port}/redis.conf：redis实例的配置文件
      - ${port}/nodes.conf：redis实例的节点文件
      - ${port}/dump.rdb：redis实例的全量数据文件
      - ${port}/appendonly.aof：redis实例的增量数据文件
  - log：存放日志信息
      - redis-cluster-trib.sh.log：创建集群的日志
      - supervisor_redis-*.log：进程监控日志

# 操作统一

为简化和统一操作，使用make命令来进行了封装,直接敲make打印下面的帮助信息

    - rebuild   rebuild image
    - run       run image to new container
    - start     start container
    - stop      stop container
    - bash      start bash with current container
    - exe      	execute command with current container,use ARGCMD='yourcmd'
    - cli       start redis-cli using first redis-ip:port instance container
    - cliall    	execute ARGCMD='yourcmd' within all containers
    - localcli  start redis-cli in localhost
    - localcliall locally execute ARGCMD='yourcmd' within all containers
    - clean     delete container
    - cleandata delete all data
    - cleanlog  delete all logs
    - distclean delete image
    - cluster 	create or check cluster,only once!

make的个性化选项：

    - REDISTYPE=mq(默认) devinfo session rating ratingcdr dupcheck autorule
    - RUNOPT=--net=host(默认) 该选择主要方便容器和宿主机双向通信，因为redis客户端集群场景下会切换ip，否则只能在容器里边使用客户端了。

# 操作方法

##镜像准备和启动

To build your own image run,Normally run once!

    # if image is exists,please firstly execute this:
    make distclean 
    # build redis instance image
    make rebuild

And to start and stop cluster:

    # prepare cluster： Firstly Configure and modify redis-cluster-volume/conf/*
    ls -l ./redis-cluster-volume/conf/*
    # start all redis instance，default container-name is redis-cluster-mq.1
    make run
    # create redis cluster，if it is only restarted,don't need execute this:
    make cluster
    # if your localhost has redis-trib.rb，Please execute this：
    make clusterinfo && ./docker-data/redis-cluster-trib.sh local your-trib-fullname

    # and top stop the container,it will firstly save cluster infomations
    # 172.17.0.2:5000> CLUSTER SAVECONFIG
    make stop
    # and restart the container
    make start
    # and start with bash
    make bash
    # delete container
    make clean

## 容器操作

To login on some container with bash:
    
    make bash

To Execute command on all container:

    make exe ARGCMD='ps -ef'
    make exe ARGCMD='ls -l /redis-cluster/*'

To execute redis-cli tool in one container:

    # client is running in some container 
    make cli
    # start redis-cli in localhost
    make localcli

    #print cluster info
    make cli ARGCMD='cluster info'

To execute redis-cli command once in all container:

    #print redis instance's info
    make cliall ARGCMD='info'

##高级操作

To need more redis instances

    # firstly,supervisor-allredis.conf need to be splitted more files
    supervisor-allredis.conf ==> supervisor-allredis.mq.1.conf supervisor-allredis.mq.2.conf supervisor-allredis.mq.3.conf
    # run this or other same of up:
    make run

To Another RedisType:

    #mq devinfo session rating ratingcdr dupcheck autorule
    make REDISTYPE="devinfo" ...  #...等同上面make后面的命令


