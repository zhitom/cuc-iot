#######################################################
#固化值
#######################################################
#镜像名字
IMGNAME?=zhitom/cuc-iot-redis-cluster:latest
#当前操作的redis集群类型
CLUSTERTYPE?=mq
#容器里边的路径
CLUSTERVOLUME?=/redis-cluster/$(CLUSTERTYPE)
#集群容器名字
CONTAINERCLUSTER?=redis-cluster.$(CLUSTERTYPE).cluster
#容器命令，某些可能需要加sudo
DOCKCMD?=docker
#外面透传给容器或客户端的命令
CMD?=""
NOCONFIRM?=n
#######################################################
#下面的根据本机情况进行修改
#######################################################
#虚拟机或本机里边的路径
VOLUMENAME?=redis-cluster-volume
VOLUMEFULLNAME?=/$(VOLUMENAME)/$(CLUSTERTYPE)
#window下，建议使用host模式，支持双向访问，否则只能容器访问外面IP，不能外面访问容器IP
RUNOPT?=--net=host

#######################################################
#计算出来的变量
#######################################################
#挂载的文件卷
VOLUMEOPT=-v $(VOLUMEFULLNAME):$(CLUSTERVOLUME)
#完整的容器列表，用空格分割,默认1个
CIDLIST?=$(shell cat ./$(VOLUMENAME)/$(CLUSTERTYPE)/conf/supervisor-allredis.cids)
#######################################################
#目标定义
#######################################################
.PHONY : help build run start stop bash exe cli cliall localcli localcliall clean cleandata cleanlog distclean cluster
help:
	@echo "Targets:"
	@echo "build        build image"
	@echo "run          run image to new container"
	@echo "start        start container"
	@echo "stop         stop container"
	@echo "bash         start bash with current container"
	@echo "exe          execute command with current container,use CMD='yourcmd'"
	@echo "cli          start redis-cli using first redis-ip:port with current container,can use CMD='yourcmd'"
	@echo "cliall       execute CMD='yourcmd' within all containers"
	@echo "localcli     start redis-cli in localhost"
	@echo "localcliall  locally execute CMD='yourcmd' within all containers"
	@echo "clean        delete container"
	@echo "cleandata    delete all data "
	@echo "cleanlog     delete all logs"
	@echo "distclean    delete image"
	@echo "cluster      create cluster,only once!"
	@echo "OPTION:"
	@echo "CLUSTERTYPE=mq(default) devinfo session rating ratingcdr dupcheck autorule"
	@echo "RUNOPT=--net=host(default) to deploy two-way commucation for conveniently Developer or Tester."
	@echo "current ContainerID List：$(CIDLIST)"

build:
	cp -f ./build-data/*.sh ./$(VOLUMENAME)/$(CLUSTERTYPE)/bin/
	chmod 0777 ./$(VOLUMENAME)/$(CLUSTERTYPE)/bin/*.sh
	$(DOCKCMD) build --no-cache=true -t $(IMGNAME) .

run:
	@echo "==>current ContainerID List：$(CIDLIST)"
	@echo "==>sync shell files ..."
	cp -f ./build-data/* ./$(VOLUMENAME)/$(CLUSTERTYPE)/bin/
	chmod 0777 ./$(VOLUMENAME)/$(CLUSTERTYPE)/bin/*
	@echo "==>empty container's instance infomation ..."
	@for port in `cat ./$(VOLUMENAME)/$(CLUSTERTYPE)/conf/redis-cluster.ports.all`; \
	do \
	if [ ! -d ./$(VOLUMENAME)/$(CLUSTERTYPE)/data/$$port ]; then \
	continue; \
	fi; \
	cp /dev/null ./$(VOLUMENAME)/$(CLUSTERTYPE)/data/$$port/redis-cluster.ip.port; \
	done
	@for cid in $(CIDLIST);do \
	echo "==>getport and redis-cluster.$(CLUSTERTYPE).$$cid"; \
	./build-data/getport.sh $(CLUSTERTYPE) $$cid; \
	echo $(DOCKCMD) run $(RUNOPT) -d `cat ./$(VOLUMENAME)/$(CLUSTERTYPE)/conf/redis-cluster.ports.$(CLUSTERTYPE).$$cid.conf` \
					$(VOLUMEOPT) --name redis-cluster.$(CLUSTERTYPE).$$cid -h redis-cluster.$(CLUSTERTYPE).$$cid --entrypoint $(CLUSTERVOLUME)/bin/docker-entrypoint.sh $(IMGNAME) $(CLUSTERTYPE) $$cid; \
	$(DOCKCMD) run $(RUNOPT) -d `cat ./$(VOLUMENAME)/$(CLUSTERTYPE)/conf/redis-cluster.ports.$(CLUSTERTYPE).$$cid.conf` \
                    $(VOLUMEOPT) --name redis-cluster.$(CLUSTERTYPE).$$cid -h redis-cluster.$(CLUSTERTYPE).$$cid --entrypoint $(CLUSTERVOLUME)/bin/docker-entrypoint.sh $(IMGNAME) $(CLUSTERTYPE) $$cid; \
    echo $(DOCKCMD) exec redis-cluster.$(CLUSTERTYPE).$$cid ps -ef; \
    $(DOCKCMD) exec redis-cluster.$(CLUSTERTYPE).$$cid ps -ef; \
    echo $(DOCKCMD) exec redis-cluster.$(CLUSTERTYPE).$$cid ifconfig; \
    $(DOCKCMD) exec redis-cluster.$(CLUSTERTYPE).$$cid ifconfig; \
    echo $(DOCKCMD) logs redis-cluster.$(CLUSTERTYPE).$$cid; \
    $(DOCKCMD) logs redis-cluster.$(CLUSTERTYPE).$$cid; \
    echo $(DOCKCMD) port redis-cluster.$(CLUSTERTYPE).$$cid; \
    $(DOCKCMD) port redis-cluster.$(CLUSTERTYPE).$$cid; \
    echo $(DOCKCMD) ps -a --filter "name=redis-cluster.$(CLUSTERTYPE).$$cid"; \
    $(DOCKCMD) ps -a --filter "name=redis-cluster.$(CLUSTERTYPE).$$cid"; \
    done

start:
	@echo "==>current ContainerID List：$(CIDLIST)"
	@for cid in $(CIDLIST);do \
	echo "==>redis-cluster.$(CLUSTERTYPE).$$cid"; \
	echo $(DOCKCMD) start redis-cluster.$(CLUSTERTYPE).$$cid; \
	$(DOCKCMD) start redis-cluster.$(CLUSTERTYPE).$$cid; \
	sleep 3; \
	echo $(DOCKCMD) exec redis-cluster.$(CLUSTERTYPE).$$cid ifconfig; \
	$(DOCKCMD) exec redis-cluster.$(CLUSTERTYPE).$$cid ifconfig; \
	echo $(DOCKCMD) logs redis-cluster.$(CLUSTERTYPE).$$cid; \
	$(DOCKCMD) logs redis-cluster.$(CLUSTERTYPE).$$cid; \
	echo $(DOCKCMD) ps -a --filter "name=redis-cluster.$(CLUSTERTYPE).$$cid"; \
	$(DOCKCMD) ps -a --filter "name=redis-cluster.$(CLUSTERTYPE).$$cid"; \
	done

stop:
	@echo "==>current ContainerID List：$(CIDLIST)"
	$(DOCKCMD) run -d --rm $(VOLUMEOPT) --name $(CONTAINERCLUSTER) -h $(CONTAINERCLUSTER) --entrypoint $(CLUSTERVOLUME)/bin/redis-cluster-trib.sh $(IMGNAME) save
	@for cid in $(CIDLIST);do \
	echo "==>redis-cluster.$(CLUSTERTYPE).$$cid"; \
	echo $(DOCKCMD) stop redis-cluster.$(CLUSTERTYPE).$$cid; \
	$(DOCKCMD) stop redis-cluster.$(CLUSTERTYPE).$$cid; \
	echo $(DOCKCMD) wait redis-cluster.$(CLUSTERTYPE).$$cid; \
	$(DOCKCMD) wait redis-cluster.$(CLUSTERTYPE).$$cid; \
	done
	$(DOCKCMD) ps -a;

bash:
	@echo "==>current ContainerID List：$(CIDLIST)"
	@for cid in $(CIDLIST);do \
	echo "==>redis-cluster.$(CLUSTERTYPE).$$cid"; \
	echo $(DOCKCMD) exec -it redis-cluster.$(CLUSTERTYPE).$$cid /bin/bash; \
	$(DOCKCMD) exec -it redis-cluster.$(CLUSTERTYPE).$$cid /bin/bash; \
	break; \
	done

exe:
	@echo "==>current ContainerID List：$(CIDLIST)"
	@for cid in $(CIDLIST);do \
	echo "==>redis-cluster.$(CLUSTERTYPE).$$cid"; \
	echo $(DOCKCMD) exec redis-cluster.$(CLUSTERTYPE).$$cid $(CMD); \
	$(DOCKCMD) exec redis-cluster.$(CLUSTERTYPE).$$cid $(CMD); \
	done

cli:
	@echo "==>current ContainerID List：$(CIDLIST)"
	@for cid in $(CIDLIST);do \
	echo "==>redis-cluster.$(CLUSTERTYPE).$$cid"; \
	echo $(DOCKCMD) exec -it redis-cluster.$(CLUSTERTYPE).$$cid /bin/bash $(CLUSTERVOLUME)/bin/redis-cli.sh 1 $(CLUSTERTYPE) $(CMD); \
	$(DOCKCMD) exec -it redis-cluster.$(CLUSTERTYPE).$$cid /bin/bash $(CLUSTERVOLUME)/bin/redis-cli.sh 1 $(CLUSTERTYPE) $(CMD); \
	break; \
	done

cliall:
	@echo "==>current ContainerID List：$(CIDLIST)"
	@for cid in $(CIDLIST);do \
	echo "==>redis-cluster.$(CLUSTERTYPE).$$cid"; \
	echo $(DOCKCMD) exec redis-cluster.$(CLUSTERTYPE).$$cid /bin/bash $(CLUSTERVOLUME)/bin/redis-cli.sh 0 $(CLUSTERTYPE) $(CMD); \
	$(DOCKCMD) exec redis-cluster.$(CLUSTERTYPE).$$cid /bin/bash $(CLUSTERVOLUME)/bin/redis-cli.sh 0 $(CLUSTERTYPE) $(CMD); \
	done

localcli:
	@for port in `cat ./$(VOLUMENAME)/$(CLUSTERTYPE)/conf/redis-cluster.ports.all`; \
	do \
	echo "==>redis-cli -c -p $$port $(CMD)"; \
	redis-cli -c -p $$port $(CMD); \
	break; \
	done

localcliall:
	@for port in `cat ./$(VOLUMENAME)/$(CLUSTERTYPE)/conf/redis-cluster.ports.all`; \
	do \
	echo "==>redis-cli -c -p $$port $(CMD)"; \
	redis-cli -c -p $$port $(CMD); \
	done

clean:
	@echo "==>current ContainerID List：$(CIDLIST)"
	@for cid in $(CIDLIST);do \
	echo "==>redis-cluster.$(CLUSTERTYPE).$$cid"; \
	echo $(DOCKCMD) container rm redis-cluster.$(CLUSTERTYPE).$$cid; \
	$(DOCKCMD) container rm redis-cluster.$(CLUSTERTYPE).$$cid; \
	done
	$(DOCKCMD) ps -a;

cleandata:
	@while [ 1 ]; do \
	echo "Cleandata Confirmed:y/n?"; \
	if [ "x$(NOCONFIRM)" = "xy" ]; then \
	y="y";echo $$y; \
	else \
	read y; \
	fi; \
	if [ "x$$y" = "xy" ]; then \
	break; \
	elif [ "x$$y" = "x" ]; then \
	continue; \
	else \
	echo "Canceled!"; \
	exit 111; \
	fi; \
	done
	rm -rf ./$(VOLUMENAME)/$(CLUSTERTYPE)/data/* ./$(VOLUMENAME)/$(CLUSTERTYPE)/data/.* 2>/dev/null||echo

cleanlog:
	rm -rf ./$(VOLUMENAME)/$(CLUSTERTYPE)/log/* ./$(VOLUMENAME)/$(CLUSTERTYPE)/log/.* 2>/dev/null||echo

distclean:
	$(DOCKCMD) rmi $(IMGNAME)
	$(DOCKCMD) images;

clusterinfo:
	-cp /dev/null ./$(VOLUMENAME)/$(CLUSTERTYPE)/data/redis-cluster.ip.port.all
	@for port in `cat ./$(VOLUMENAME)/$(CLUSTERTYPE)/conf/redis-cluster.ports.all`; \
	do \
	if [ "x$$port" = "x" ]; then \
	continue; \
	fi; \
	cat ./$(VOLUMENAME)/$(CLUSTERTYPE)/data/$$port/redis-cluster.ip.port 2>/dev/null >> ./$(VOLUMENAME)/$(CLUSTERTYPE)/data/redis-cluster.ip.port.all ; \
	done
	cat ./$(VOLUMENAME)/$(CLUSTERTYPE)/data/redis-cluster.ip.port.all|sort -u > ./$(VOLUMENAME)/$(CLUSTERTYPE)/data/redis-cluster.ip.port.all.tmp
	mv -f ./$(VOLUMENAME)/$(CLUSTERTYPE)/data/redis-cluster.ip.port.all.tmp ./$(VOLUMENAME)/$(CLUSTERTYPE)/data/redis-cluster.ip.port.all 2>/dev/null
	cat ./$(VOLUMENAME)/$(CLUSTERTYPE)/data/redis-cluster.ip.port.all

cluster:clusterinfo
	-rm -f ./$(VOLUMENAME)/$(CLUSTERTYPE)/log/redis-cluster-trib.sh.log 2>/dev/null
	@echo "run new container for ${CLUSTERVOLUME}/bin/redis-cluster-trib.sh ${CLUSTERTYPE} ..."
	$(DOCKCMD) run -d --rm  $(VOLUMEOPT) --name $(CONTAINERCLUSTER) -h $(CONTAINERCLUSTER) --entrypoint $(CLUSTERVOLUME)/bin/redis-cluster-trib.sh $(IMGNAME) ${CLUSTERTYPE}
	sleep 5
	-cat ./$(VOLUMENAME)/$(CLUSTERTYPE)/log/redis-cluster-trib.sh.log 2>/dev/null




