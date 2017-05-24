#######################################################
#固化值
#######################################################
#镜像名字
IMGNAME?=zhitom/cuc-iot-redis-cluster:latest
#当前操作的redis集群类型
REDISTYPE?=mq
#容器里边的路径
REDISVOLUME?=/redis-cluster/$(REDISTYPE)
#集群容器名字
CONTAINERCLUSTER?=redis-cluster.$(REDISTYPE).cluster
#容器命令，某些可能需要加sudo
DOCKCMD?=docker
#外面透传给容器或客户端的命令
ARGCMD?=""
#######################################################
#下面的根据本机情况进行修改
#######################################################
#虚拟机或本机里边的路径
VOLUMENAME?=redis-cluster-volume
VOLUMEFULLNAME?=/$(VOLUMENAME)/$(REDISTYPE)
#window下，建议使用host模式，支持双向访问，否则只能容器访问外面IP，不能外面访问容器IP
RUNOPT?=--net=host

#######################################################
#计算出来的变量
#######################################################
#挂载的文件卷
VOLUMEOPT=-v $(VOLUMEFULLNAME):$(REDISVOLUME)
#完整的容器列表，用空格分割,默认1个
CIDLIST?=$(shell cat ./$(VOLUMENAME)/$(REDISTYPE)/conf/supervisor-allredis.cids)
#######################################################
#目标定义
#######################################################
.PHONY : help build run start stop bash exe cli cliall localcli localcliall clean cleandata cleanlog distclean cluster
help:
	@echo "Targets:"
	@echo "build  	    build image"
	@echo "run      	run image to new container"
	@echo "start    	start container"
	@echo "stop     	stop container"
	@echo "bash      	start bash with current container"
	@echo "exe      	execute command with current container,use ARGCMD='yourcmd'"
	@echo "cli    	 	start redis-cli using first redis-ip:port with current container,can use ARGCMD='yourcmd'"
	@echo "cliall    	execute ARGCMD='yourcmd' within all containers"
	@echo "localcli 	start redis-cli in localhost"
	@echo "localcliall 	locally execute ARGCMD='yourcmd' within all containers"
	@echo "clean    	delete container"
	@echo "cleandata  	delete all data "
	@echo "cleanlog 	delete all logs"
	@echo "distclean 	delete image"
	@echo "cluster   	create cluster,only once!"
	@echo "OPTION:"
	@echo "REDISTYPE=mq(default) devinfo session rating ratingcdr dupcheck autorule"
	@echo "RUNOPT=--net=host(default) to deploy two-way commucation for conveniently Developer or Tester."
	@echo "current ContainerID List：$(CIDLIST)"

build:
	cp -f ./build-data/*.sh ./$(VOLUMENAME)/$(REDISTYPE)/bin/
	chmod 0777 ./$(VOLUMENAME)/$(REDISTYPE)/bin/*.sh
	$(DOCKCMD) build --no-cache=true -t $(IMGNAME) .

run:
	@echo "==>current ContainerID List：$(CIDLIST)"
	@echo "==>sync shell files ..."
	cp -f ./build-data/*.sh ./$(VOLUMENAME)/$(REDISTYPE)/bin/
	chmod 0777 ./$(VOLUMENAME)/$(REDISTYPE)/bin/*.sh
	@echo "==>empty container's instance infomation ..."
	@for port in `cat ./$(VOLUMENAME)/$(REDISTYPE)/conf/redis-cluster.ports.all`; \
	do \
	if [ ! -d ./$(VOLUMENAME)/$(REDISTYPE)/data/$$port ]; then \
	continue; \
	fi; \
	cp /dev/null ./$(VOLUMENAME)/$(REDISTYPE)/data/$$port/redis-cluster.ip.port; \
	done
	@for cid in $(CIDLIST);do \
	echo "==>getport and redis-cluster.$(REDISTYPE).$$cid"; \
	./build-data/getport.sh $(REDISTYPE) $$cid; \
	echo $(DOCKCMD) run $(RUNOPT) -d `cat ./$(VOLUMENAME)/$(REDISTYPE)/conf/redis-cluster.ports.$(REDISTYPE).$$cid.conf` \
					$(VOLUMEOPT) --name redis-cluster.$(REDISTYPE).$$cid -h redis-cluster.$(REDISTYPE).$$cid --entrypoint $(REDISVOLUME)/bin/docker-entrypoint.sh $(IMGNAME) $(REDISTYPE) $$cid; \
	$(DOCKCMD) run $(RUNOPT) -d `cat ./$(VOLUMENAME)/$(REDISTYPE)/conf/redis-cluster.ports.$(REDISTYPE).$$cid.conf` \
                    $(VOLUMEOPT) --name redis-cluster.$(REDISTYPE).$$cid -h redis-cluster.$(REDISTYPE).$$cid --entrypoint $(REDISVOLUME)/bin/docker-entrypoint.sh $(IMGNAME) $(REDISTYPE) $$cid; \
    echo $(DOCKCMD) exec redis-cluster.$(REDISTYPE).$$cid ps -ef; \
    $(DOCKCMD) exec redis-cluster.$(REDISTYPE).$$cid ps -ef; \
    echo $(DOCKCMD) exec redis-cluster.$(REDISTYPE).$$cid ifconfig; \
    $(DOCKCMD) exec redis-cluster.$(REDISTYPE).$$cid ifconfig; \
    echo $(DOCKCMD) logs redis-cluster.$(REDISTYPE).$$cid; \
    $(DOCKCMD) logs redis-cluster.$(REDISTYPE).$$cid; \
    echo $(DOCKCMD) port redis-cluster.$(REDISTYPE).$$cid; \
    $(DOCKCMD) port redis-cluster.$(REDISTYPE).$$cid; \
    echo $(DOCKCMD) ps -a --filter "name=redis-cluster.$(REDISTYPE).$$cid"; \
    $(DOCKCMD) ps -a --filter "name=redis-cluster.$(REDISTYPE).$$cid"; \
    done

start:
	@echo "==>current ContainerID List：$(CIDLIST)"
	@for cid in $(CIDLIST);do \
	echo "==>redis-cluster.$(REDISTYPE).$$cid"; \
	echo $(DOCKCMD) start redis-cluster.$(REDISTYPE).$$cid; \
	$(DOCKCMD) start redis-cluster.$(REDISTYPE).$$cid; \
	sleep 3; \
	echo $(DOCKCMD) exec redis-cluster.$(REDISTYPE).$$cid ifconfig; \
	$(DOCKCMD) exec redis-cluster.$(REDISTYPE).$$cid ifconfig; \
	echo $(DOCKCMD) logs redis-cluster.$(REDISTYPE).$$cid; \
	$(DOCKCMD) logs redis-cluster.$(REDISTYPE).$$cid; \
	echo $(DOCKCMD) ps -a --filter "name=redis-cluster.$(REDISTYPE).$$cid"; \
	$(DOCKCMD) ps -a --filter "name=redis-cluster.$(REDISTYPE).$$cid"; \
	done

stop:
	@echo "==>current ContainerID List：$(CIDLIST)"
	$(DOCKCMD) run -d --rm $(VOLUMEOPT) --name $(CONTAINERCLUSTER) -h $(CONTAINERCLUSTER) --entrypoint $(REDISVOLUME)/bin/redis-cluster-trib.sh $(IMGNAME) save
	@for cid in $(CIDLIST);do \
	echo "==>redis-cluster.$(REDISTYPE).$$cid"; \
	echo $(DOCKCMD) stop redis-cluster.$(REDISTYPE).$$cid; \
	$(DOCKCMD) stop redis-cluster.$(REDISTYPE).$$cid; \
	echo $(DOCKCMD) wait redis-cluster.$(REDISTYPE).$$cid; \
	$(DOCKCMD) wait redis-cluster.$(REDISTYPE).$$cid; \
	done
	$(DOCKCMD) ps -a;

bash:
	@echo "==>current ContainerID List：$(CIDLIST)"
	@for cid in $(CIDLIST);do \
	echo "==>redis-cluster.$(REDISTYPE).$$cid"; \
	echo $(DOCKCMD) exec -it redis-cluster.$(REDISTYPE).$$cid /bin/bash; \
	$(DOCKCMD) exec -it redis-cluster.$(REDISTYPE).$$cid /bin/bash; \
	break; \
	done

exe:
	@echo "==>current ContainerID List：$(CIDLIST)"
	@for cid in $(CIDLIST);do \
	echo "==>redis-cluster.$(REDISTYPE).$$cid"; \
	echo $(DOCKCMD) exec redis-cluster.$(REDISTYPE).$$cid $(ARGCMD); \
	$(DOCKCMD) exec redis-cluster.$(REDISTYPE).$$cid $(ARGCMD); \
	done

cli:
	@echo "==>current ContainerID List：$(CIDLIST)"
	@for cid in $(CIDLIST);do \
	echo "==>redis-cluster.$(REDISTYPE).$$cid"; \
	echo $(DOCKCMD) exec -it redis-cluster.$(REDISTYPE).$$cid /bin/bash $(REDISVOLUME)/bin/redis-cli.sh 1 $(REDISTYPE) $(ARGCMD); \
	$(DOCKCMD) exec -it redis-cluster.$(REDISTYPE).$$cid /bin/bash $(REDISVOLUME)/bin/redis-cli.sh 1 $(REDISTYPE) $(ARGCMD); \
	break; \
	done

cliall:
	@echo "==>current ContainerID List：$(CIDLIST)"
	@for cid in $(CIDLIST);do \
	echo "==>redis-cluster.$(REDISTYPE).$$cid"; \
	echo $(DOCKCMD) exec redis-cluster.$(REDISTYPE).$$cid /bin/bash $(REDISVOLUME)/bin/redis-cli.sh 0 $(REDISTYPE) $(ARGCMD); \
	$(DOCKCMD) exec redis-cluster.$(REDISTYPE).$$cid /bin/bash $(REDISVOLUME)/bin/redis-cli.sh 0 $(REDISTYPE) $(ARGCMD); \
	done

localcli:
	@for port in `cat ./$(VOLUMENAME)/$(REDISTYPE)/conf/redis-cluster.ports.all`; \
	do \
	echo "==>redis-cli -c -p $$port $(ARGCMD)"; \
	redis-cli -c -p $$port $(ARGCMD); \
	break; \
	done

localcliall:
	@for port in `cat ./$(VOLUMENAME)/$(REDISTYPE)/conf/redis-cluster.ports.all`; \
	do \
	echo "==>redis-cli -c -p $$port $(ARGCMD)"; \
	redis-cli -c -p $$port $(ARGCMD); \
	done

clean:
	@echo "==>current ContainerID List：$(CIDLIST)"
	@for cid in $(CIDLIST);do \
	echo "==>redis-cluster.$(REDISTYPE).$$cid"; \
	echo $(DOCKCMD) container rm redis-cluster.$(REDISTYPE).$$cid; \
	$(DOCKCMD) container rm redis-cluster.$(REDISTYPE).$$cid; \
	done
	$(DOCKCMD) ps -a;

cleandata:
	@while [ 1 ];do \
	echo "Cleandata Confirmed:y/n?"; \
	read y; \
	if [ "x$$y" = "xy" ]; then \
	break; \
	elif [ "x$$y" = "x" ]; then \
	continue; \
	else \
	echo "Canceled!"; \
	exit 111; \
	fi; \
	done
	rm -rf ./$(VOLUMENAME)/$(REDISTYPE)/data/* 2>/dev/null

cleanlog:
	rm -rf ./$(VOLUMENAME)/$(REDISTYPE)/log/* 2>/dev/null

distclean:
	$(DOCKCMD) rmi $(IMGNAME)
	$(DOCKCMD) images;

clusterinfo:
	-cp /dev/null ./$(VOLUMENAME)/$(REDISTYPE)/data/redis-cluster.ip.port.all
	@for port in `cat ./$(VOLUMENAME)/$(REDISTYPE)/conf/redis-cluster.ports.all`; \
	do \
	if [ "x$$port" = "x" ]; then \
	continue; \
	fi; \
	cat ./$(VOLUMENAME)/$(REDISTYPE)/data/$$port/redis-cluster.ip.port 2>/dev/null >> ./$(VOLUMENAME)/$(REDISTYPE)/data/redis-cluster.ip.port.all ; \
	done
	cat ./$(VOLUMENAME)/$(REDISTYPE)/data/redis-cluster.ip.port.all|sort -u > ./$(VOLUMENAME)/$(REDISTYPE)/data/redis-cluster.ip.port.all.tmp
	mv -f ./$(VOLUMENAME)/$(REDISTYPE)/data/redis-cluster.ip.port.all.tmp ./$(VOLUMENAME)/$(REDISTYPE)/data/redis-cluster.ip.port.all 2>/dev/null
	cat ./$(VOLUMENAME)/$(REDISTYPE)/data/redis-cluster.ip.port.all

cluster:clusterinfo
	-rm -f ./$(VOLUMENAME)/$(REDISTYPE)/log/redis-cluster-trib.sh.log 2>/dev/null
	@echo "run new container for ${REDISVOLUME}/bin/redis-cluster-trib.sh ${REDISTYPE} ..."
	$(DOCKCMD) run -d --rm  $(VOLUMEOPT) --name $(CONTAINERCLUSTER) -h $(CONTAINERCLUSTER) --entrypoint $(REDISVOLUME)/bin/redis-cluster-trib.sh $(IMGNAME) ${REDISTYPE}
	sleep 5
	-cat ./$(VOLUMENAME)/$(REDISTYPE)/log/redis-cluster-trib.sh.log 2>/dev/null




