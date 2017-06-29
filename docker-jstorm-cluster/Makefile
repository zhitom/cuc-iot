#######################################################
#固化值
#######################################################
#镜像名字
IMGNAME?=zhitom/docker-jstorm-cluster:latest
#当前操作的集群类型
CLUSTERTYPE?=offline
SERVICENAME?=$(CLUSTERTYPE)-1
PROJECTNAME?=p$(CLUSTERTYPE)
NETWORKNAME=$(PROJECTNAME)_default
#容器里边的路径
CLUSTERVOLUME?=/jstorm-cluster/$(CLUSTERTYPE)
#集群容器名字
CONTAINERCLUSTER?=jstorm-cluster.$(CLUSTERTYPE).cluster
#服务实例编号，暂支持1个，默认从1开始
CONTAINERINDEX?=1
#容器命令，某些可能需要加sudo
#docker-machine所在机器或虚拟机的机器名、ip
VM=${DOCKER_MACHINE_NAME-default}
DOCKER_MACHINE=docker-machine
IP=$(shell $(DOCKER_MACHINE) ip $(VM))
DOCKCMD?=docker
DOCKCOMPCMD?=docker-compose -f docker-compose-$(CLUSTERTYPE).yml
#外面透传给容器或客户端的命令
CMD?=""
NOCONFIRM?=n
#######################################################
#下面的根据本机情况进行修改
#######################################################
#虚拟机或本机里边的路径
VOLUMENAME?=jstorm-cluster-volume
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
	@NONEMID=`$(DOCKCMD) images|grep '^<none>'|awk '{print $$3}'`;echo none image=$$NONEMID; \
	if [ "x$$NONEMID" != "x" ]; then \
		for mid in $$NONEMID;do \
			NONECID=`$(DOCKCMD) ps -a|grep $$mid|awk '{print $$1}'`;echo none container=$$NONECID; \
			if [ "x$$NONECID" != "x" ]; then \
				$(DOCKCMD) rm $$NONECID; \
			fi; \
		done; \
		$(DOCKCMD) rmi $$NONEMID; \
	fi;
	$(DOCKCMD) pull $(IMGNAME)
	exit 0
	@echo "==>build $(IMGNAME) ..."
	@NONEMID=`$(DOCKCMD) images|grep '^<none>'|awk '{print $$3}'`;echo none image=$$NONEMID; \
	if [ "x$$NONEMID" != "x" ]; then \
		for mid in $$NONEMID;do \
			NONECID=`$(DOCKCMD) ps -a|grep $$mid|awk '{print $$1}'`;echo none container=$$NONECID; \
			if [ "x$$NONECID" != "x" ]; then \
				$(DOCKCMD) rm $$NONECID; \
			fi; \
		done; \
		$(DOCKCMD) rmi $$NONEMID; \
	fi;
	$(DOCKCMD) build --no-cache=true -t $(IMGNAME) .

run:
	@echo "==>prepare shell ..."
	mkdir -p $(VOLUMEFULLNAME)/bin/
	cp ./build-data/* $(VOLUMEFULLNAME)/bin/
	chmod 0777 $(VOLUMEFULLNAME)/bin/*
	@echo "==>jstorm-cluster.$(CLUSTERTYPE),up services: start all containers..."; 
	$(DOCKCOMPCMD) -p $(PROJECTNAME) up -d --no-recreate; 
	@for svc in `$(DOCKCOMPCMD) -p $(PROJECTNAME) config --services`;do \
	svc="`echo $${svc}`"; \
	echo "=============================================================="; \
	echo "==>container name=$(PROJECTNAME)_$${svc}"; \
	echo "==>"$(DOCKCOMPCMD) -p $(PROJECTNAME) logs --tail=100 $${svc}; \
	$(DOCKCOMPCMD) -p $(PROJECTNAME) logs --tail=100 $${svc}; \
	done
	@for svc in `$(DOCKCOMPCMD) -p $(PROJECTNAME) config --services`;do \
	svc="`echo $${svc}`"; \
	echo "=============================================================="; \
	echo "==>container name=$(PROJECTNAME)_$${svc}"; \
	echo "==>"$(DOCKCMD) exec -it $(PROJECTNAME)_$${svc}_$(CONTAINERINDEX) ps -ef; \
	$(DOCKCMD) exec -it $(PROJECTNAME)_$${svc}_$(CONTAINERINDEX) ps -ef; \
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
	@for svc in `$(DOCKCOMPCMD) -p $(PROJECTNAME) config --services`;do \
	svc="`echo $${svc}`"; \
	echo "=============================================================="; \
	echo "==>container name=$(PROJECTNAME)_$${svc}"; \
	echo "==>"$(DOCKCMD) exec -it $(PROJECTNAME)_$${svc}_$(CONTAINERINDEX) $(CLUSTERVOLUME)/bin/jstorm.sh $(CLUSTERTYPE) info; \
	$(DOCKCMD) exec -it $(PROJECTNAME)_$${svc}_$(CONTAINERINDEX) $(CLUSTERVOLUME)/bin/jstorm.sh $(CLUSTERTYPE) info; \
	break; \
	done
	@echo "==>services status ..."
	$(DOCKCOMPCMD) -p $(PROJECTNAME) ps ;
	$(DOCKCMD) ps -f name="$(PROJECTNAME)_*";
	@echo "==>network status ..."
	$(DOCKCMD) network ls -f name=$(NETWORKNAME);

start:run

stop:
	@echo "==>down services: stop all containers...";
	@for svc in `$(DOCKCOMPCMD) -p $(PROJECTNAME) config --services`;do \
	svc="`echo $${svc}`"; \
	echo "=============================================================="; \
	echo "==>"$(DOCKCMD) exec -it $(PROJECTNAME)_$${svc}_$(CONTAINERINDEX) $(CLUSTERVOLUME)/bin/jstorm.sh $(CLUSTERTYPE) stop ; \
	$(DOCKCMD) exec -it $(PROJECTNAME)_$${svc}_$(CONTAINERINDEX) $(CLUSTERVOLUME)/bin/jstorm.sh $(CLUSTERTYPE) stop; \
	done
	@echo "==>services stop ..."
	$(DOCKCOMPCMD) -p $(PROJECTNAME) stop; 
	@echo "==>services status ..."
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
	echo "==>"$(DOCKCMD) exec -it $(PROJECTNAME)_$${svc}_$(CONTAINERINDEX) $(CLUSTERVOLUME)/bin/jstorm.sh $(CLUSTERTYPE) $(CMD); \
	$(DOCKCMD) exec -it $(PROJECTNAME)_$${svc}_$(CONTAINERINDEX) $(CLUSTERVOLUME)/bin/jstorm.sh $(CLUSTERTYPE) $(CMD); \
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
	@echo "==>down services: rm all containers...";
	$(DOCKCOMPCMD) -p $(PROJECTNAME) down; 
	@echo "==>services status ...";
	$(DOCKCOMPCMD) -p $(PROJECTNAME) ps ;
	@echo "==>network status ...";
	$(DOCKCMD) network ls -f name=$(NETWORKNAME);

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
	rm -rf ./$(VOLUMENAME)/$(CLUSTERTYPE)/*/data/* ./$(VOLUMENAME)/$(CLUSTERTYPE)/*/datalog/* ./$(VOLUMENAME)/$(CLUSTERTYPE)/*/data/.* ./$(VOLUMENAME)/$(CLUSTERTYPE)/*/datalog/.* 2>/dev/null||echo

cleanlog:
	rm -rf ./$(VOLUMENAME)/$(CLUSTERTYPE)/*/log/* ./$(VOLUMENAME)/$(CLUSTERTYPE)/*/log/.* 2>/dev/null||echo

distclean:
	@echo "==>rmi image: $(IMGNAME)";
	$(DOCKCMD) rmi $(IMGNAME)
	@echo "==>list image:";
	$(DOCKCMD) images;

clusterinfo:
	

cluster:
	@echo "==>UnSupported!"



