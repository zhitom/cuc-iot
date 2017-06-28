# jstorm-cluster

# 概述

jstorm-cluster是在[mtunique/jstorm](https://hub.docker.com/r/mtunique/jstorm/)基础之上修改创建的，使用了docker-compose来管理对应的容器，同时使用了环境变量来个性化集群配置。

- git里边会预配置5个集群，可以使用docker -f <your choose>.yaml来启动对应的集群
- JSTORM_HOME为jstorm开源软件的HOME目录，指向/opt/jstorm
- JSTORM_CLUSTER默认指向JSTORM_HOME，用于指定存放数据和配置信息的根目录


# 版本

- jstorm.latest == 2.2.1

# Windows7 or Windows10

由于windows下面使用了boot2docker.iso,所以需先打开VirtualBox，设置一下此虚拟机：

- 设置目录共享jstorm-cluster-volume为jstorm-cluster-volume，路径为/jstorm-cluster-volume
- 本机是指该虚拟机，非windows系统，所以
    - 本地IP为的虚拟机IP，一般是192.168.99.100，具体需看VirtualBox的配置
    - 端口映射到的是虚拟机上面的端口
    - ssh登录：user=docker，password=tcuser
    - 由于是集群，查询key的时候会切换ip:port，所以要将容器的网络作为host模式启动
        - 此选项在Makefile.HOSTOPT设置为‘--net=host’，如果本机为linux的就设置为空即可
        - 否则只能在容器里边使用客户端查询
- 因使用了makefile，所以进入docker的mingw环境需要提供make命令，本人将cygwin的make命令直接copy到了mingw环境里边可能/bin/sh也有类似的问题，可以直接将bash.exe拷贝成sh.exe

# 持久化

根据windows或linux的不同，需修改Makefile.WINVOLUMEPATH和VOLUMENAME路径信息：

- windows
    - VOLUMEFULLNAME：为虚拟机里边的路径，需要先在VirtualBox加载目录
- Linux
    - VOLUMEFULLNAME：为虚拟机里边的路径
- 目前除了mq和session不需要数据持久化外，其他jstorm都进行了数据持久化的配置
- 集群信息本身还是需要持久化，所以持久化的文件卷不能少。

# 目录文件说明

- Makefile和Dockerfile用于创建该镜像
- build-data：源码目录，用于创建该镜像
  - common.sh：公共函数
  - jstorm.sh：启动jstorm实例
- jstorm-cluster-volume：为容器持久化和共享的文件夹,动态产生
  - bin：存放可执行脚本，同build-data下面的*.sh,创建镜像时makefile里边自动同步
  - conf：存放配置及模版文件
  - data：存放jstorm持久化的文件
  - log：存放日志信息

# 操作统一

为简化和统一操作，使用make命令来进行了封装,直接敲make打印下面的帮助信息

    - build     build image
    - run       run image to new container
    - start     start container
    - stop      stop container
    - bash      start bash with current container
    - exe      	execute command with current container,use CMD='yourcmd'
    - cli       start jstorm-cli using first jstorm-ip:port instance container
    - cliall    	execute CMD='yourcmd' within all containers
    - localcli  start jstorm-cli in localhost
    - localcliall locally execute CMD='yourcmd' within all containers
    - clean     delete container
    - cleandata delete all data
    - cleanlog  delete all logs
    - distclean delete image
    - cluster 	create or check cluster,only once!

make的个性化选项：

    - CLUSTERTYPE=offline(默认) cb autorule infomgr acctout
    - RUNOPT=--net=host(默认) 增加可以启动容器时可以扩展的选项。

# 操作方法

##镜像准备和启动

To build your own image run,Normally run once!

    # if image is exists,please firstly execute this:
    make distclean 
    # build jstorm instance image
    make build

And to start and stop cluster:

    # start all jstorm instance，default container-name is poffline_jstormcluster-offline-1_1
    make run
    # and top stop the container,it will firstly save cluster infomations
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

    make exe CMD='ps -ef'
    make exe CMD='ls -l /jstorm-cluster/*'

To execute jstorm-cli tool in one container:

    # client is running in some container 
    make cli
    # start jstorm-cli in localhost
    make localcli

    #print cluster info
    make cli CMD='info'

To execute jstorm-cli command once in all container:

    #print jstorm instance's info
    make cliall CMD='info'

##高级操作

To Another ClusterType:

    #CLUSTERTYPE=offline(默认) cb autorule infomgr acctout
    make CLUSTERTYPE="autorule" ...  #...等同上面make后面的命令


