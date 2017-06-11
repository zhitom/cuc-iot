#######################################################
#固化值
#######################################################
#镜像名字
IMGNAME?=wurstmeister/kafka
#当前操作的集群类型
CLUSTERTYPE?=f2m
SERVICENAME?=$(CLUSTERTYPE)-1
PROJECTNAME?=p$(CLUSTERTYPE)
NETWORKNAME=$(PROJECTNAME)_default
#容器里边的路径
CLUSTERVOLUME?=/kafka-cluster/$(CLUSTERTYPE)
#集群容器名字
CONTAINERCLUSTER?=kafka-cluster.$(CLUSTERTYPE).cluster
#服务实例编号，暂支持1个，默认从1开始
CONTAINERINDEX?=1
#容器命令，某些可能需要加sudo
DOCKCMD?=docker
DOCKCOMPCMD?=docker-compose -f docker-compose-$(CLUSTERTYPE).yml
#外面透传给容器或客户端的命令
CMD?="env"
#######################################################
#下面的根据本机情况进行修改
#######################################################
#虚拟机或本机里边的路径
VOLUMENAME?=kafka-cluster-volume
VOLUMEFULLNAME?=./$(VOLUMENAME)/$(CLUSTERTYPE)

#######################################################
#计算出来的变量
#######################################################
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
	@echo "CLUSTERTYPE=f2m(default) m2f info offline cb autorule infomgr acctout"

build:
	@echo "Use directly OFFICIAL image: docker pull $(IMGNAME)"
	$(DOCKCMD) pull $(IMGNAME)

run:
	mkdir -p $(VOLUMEFULLNAME)/bin/
	cp ./build-data/*sh $(VOLUMEFULLNAME)/bin/
	chmod 0777 $(VOLUMEFULLNAME)/bin/*.sh
	@echo "==>kafka-cluster.$(CLUSTERTYPE),up services: start all containers..."; 
	$(DOCKCOMPCMD) -p $(PROJECTNAME) up -d --no-recreate; 
	@for svc in `$(DOCKCOMPCMD) -p $(PROJECTNAME) config --services`;do \
	svc="`echo $${svc}`"; \
	echo "=============================================================="; \
	echo "==>container name=$(PROJECTNAME)_$${svc}"; \
	echo "==>"$(DOCKCOMPCMD) -p $(PROJECTNAME) logs --tail=30 $${svc}; \
	$(DOCKCOMPCMD) -p $(PROJECTNAME) logs --tail=30 $${svc}; \
	done
	@for svc in `$(DOCKCOMPCMD) -p $(PROJECTNAME) config --services`;do \
	svc="`echo $${svc}`"; \
	echo "=============================================================="; \
	echo "==>container name=$(PROJECTNAME)_$${svc}"; \
	echo "==>"$(DOCKCOMPCMD) -p $(PROJECTNAME) exec $${svc} ps -ef; \
	$(DOCKCOMPCMD) -p $(PROJECTNAME) exec $${svc} ps -ef; \
	echo "==>"$(DOCKCOMPCMD) -p $(PROJECTNAME) exec $${svc} ifconfig; \
	$(DOCKCOMPCMD) -p $(PROJECTNAME) exec $${svc} ifconfig; \
	echo "==>"$(DOCKCMD) port $(PROJECTNAME)_$${svc}_$(CONTAINERINDEX); \
	$(DOCKCMD) port $(PROJECTNAME)_$${svc}_$(CONTAINERINDEX); \
	done
	@for svc in `$(DOCKCOMPCMD) -p $(PROJECTNAME) config --services`;do \
	svc="`echo $${svc}`"; \
	echo "=============================================================="; \
	echo "==>container name=$(PROJECTNAME)_$${svc}"; \
	echo "==>"$(DOCKCOMPCMD) -p $(PROJECTNAME) exec $${svc} netstat -natp; \
	$(DOCKCOMPCMD) -p $(PROJECTNAME) exec $${svc} netstat -natp; \
	done
	$(DOCKCOMPCMD) -p $(PROJECTNAME) ps ;
	$(DOCKCMD) network ls -f name=$(NETWORKNAME);
	
start:run

stop:
	@echo "down services: stop all containers...";
	@for svc in `$(DOCKCOMPCMD) -p $(PROJECTNAME) config --services`;do \
	svc="`echo $${svc}`"; \
	echo "=============================================================="; \
	echo $(DOCKCMD) exec -it $(PROJECTNAME)_$${svc}_$(CONTAINERINDEX) $(CLUSTERVOLUME)/bin/mykafka.sh stop ; \
	$(DOCKCMD) exec -it $(PROJECTNAME)_$${svc}_$(CONTAINERINDEX) $(CLUSTERVOLUME)/bin/mykafka.sh stop; \
	done
	$(DOCKCOMPCMD) -p $(PROJECTNAME) stop; 
	$(DOCKCOMPCMD) -p $(PROJECTNAME) ps ;

bash:
	@for svc in `$(DOCKCOMPCMD) -p $(PROJECTNAME) config --services`;do \
	svc="`echo $${svc}`"; \
	echo "=============================================================="; \
	echo "==>container name=$(PROJECTNAME)_$${svc}"; \
	echo $(DOCKCMD) exec -it $(PROJECTNAME)_$${svc}_$(CONTAINERINDEX) /bin/bash; \
	$(DOCKCMD) exec -it $(PROJECTNAME)_$${svc}_$(CONTAINERINDEX) /bin/bash; \
	break; \
	done

exe:
	@for svc in `$(DOCKCOMPCMD) -p $(PROJECTNAME) config --services`;do \
	svc="`echo $${svc}`"; \
	echo "=============================================================="; \
	echo "==>container name=$(PROJECTNAME)_$${svc}"; \
	echo "==>"$(DOCKCMD) exec -it $(PROJECTNAME)_$${svc}_$(CONTAINERINDEX) $(CLUSTERVOLUME)/bin/mykafka.sh $(CMD); \
	$(DOCKCMD) exec -it $(PROJECTNAME)_$${svc}_$(CONTAINERINDEX) $(CLUSTERVOLUME)/bin/mykafka.sh $(CMD); \
	done

cli:
	@echo "==>UnSupported!"

cliall:
	@echo "==>UnSupported!"

localcli:
	@echo "==>UnSupported!"

localcliall:
	@echo "==>UnSupported!"

clean:
	@echo "down services: rm all containers...";
	$(DOCKCOMPCMD) -p $(PROJECTNAME) down; 
	$(DOCKCOMPCMD) -p $(PROJECTNAME) ps ;
	$(DOCKCMD) network ls -f name=$(NETWORKNAME);

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
	rm -rf ./$(VOLUMENAME)/$(CLUSTERTYPE)/*/data/* ./$(VOLUMENAME)/$(CLUSTERTYPE)/*/datalog/* 2>/dev/null

cleanlog:
	rm -rf ./$(VOLUMENAME)/$(CLUSTERTYPE)/*/log/* 2>/dev/null

distclean:
	$(DOCKCMD) rmi $(IMGNAME)
	$(DOCKCMD) images;

clusterinfo:
	

cluster:
	@echo "==>UnSupported!"




