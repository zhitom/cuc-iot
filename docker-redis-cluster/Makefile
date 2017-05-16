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
#完整的容器列表，用空格分割,默认1个
CIDLIST?="1"
#容器命令，某些可能需要加sudo
DOCKCMD?=docker
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
#暴露需映射的端口
PORTOPT=$(shell for p in `cat ./$(VOLUMENAME)/$(REDISTYPE)/conf/redis-cluster.ports.all 2>/dev/null`;do \
					CLIENTPORT="$${CLIENTPORT} -p $$p:$$p"; \
					done&&echo $${CLIENTPORT})
#挂载的文件卷
VOLUMEOPT=-v $(VOLUMEFULLNAME)/bin:$(REDISVOLUME)/bin \
		  -v $(VOLUMEFULLNAME)/conf:$(REDISVOLUME)/conf \
		  -v $(VOLUMEFULLNAME)/data:$(REDISVOLUME)/data \
		  -v $(VOLUMEFULLNAME)/log:$(REDISVOLUME)/log
#######################################################
#目标定义
#######################################################
help:
	@echo "rebuild  	rebuild image"
	@echo "run      	run image to new container"
	@echo "start    	start container"
	@echo "stop     	stop container"
	@echo "bash      	start bash with current container"
	@echo "cli    	 	start redis-cli using first redis-ip:port with current container"
	@echo "clean    	delete container"
	@echo "cleandata  	delete all data and logs"
	@echo "distclean 	delete image"
	@echo "cluster   	create cluster,only once!"

rebuild:
	$(DOCKCMD) build --no-cache=true -t $(IMGNAME) .

run:
	@for port in `cat ./$(VOLUMENAME)/$(REDISTYPE)/conf/redis-cluster.ports.all`; \
	do \
	if [ ! -d ./$(VOLUMENAME)/$(REDISTYPE)/data/$$port ]; then \
	continue; \
	fi; \
	cp /dev/null ./$(VOLUMENAME)/$(REDISTYPE)/data/$$port/redis-cluster.ip.port; \
	done
	@for cid in $(CIDLIST);do \
	echo "==>redis-cluster.$(REDISTYPE).$$cid"; \
	echo $(DOCKCMD) run $(RUNOPT) -d $(PORTOPT) $(VOLUMEOPT) --name redis-cluster.$(REDISTYPE).$$cid -h redis-cluster.$(REDISTYPE).$$cid --entrypoint $(REDISVOLUME)/bin/docker-entrypoint.sh $(IMGNAME) $(REDISTYPE); \
	$(DOCKCMD) run $(RUNOPT) -d $(PORTOPT) $(VOLUMEOPT) --name redis-cluster.$(REDISTYPE).$$cid -h redis-cluster.$(REDISTYPE).$$cid --entrypoint $(REDISVOLUME)/bin/docker-entrypoint.sh $(IMGNAME) $(REDISTYPE); \
	echo $(DOCKCMD) exec redis-cluster.$(REDISTYPE).$$cid ifconfig; \
	$(DOCKCMD) exec redis-cluster.$(REDISTYPE).$$cid ifconfig; \
	echo $(DOCKCMD) logs redis-cluster.$(REDISTYPE).$$cid; \
	$(DOCKCMD) logs redis-cluster.$(REDISTYPE).$$cid; \
	echo $(DOCKCMD) port redis-cluster.$(REDISTYPE).$$cid; \
	$(DOCKCMD) port redis-cluster.$(REDISTYPE).$$cid; \
	done

start:
	@for cid in $(CIDLIST);do \
	echo "==>redis-cluster.$(REDISTYPE).$$cid"; \
	echo $(DOCKCMD) start redis-cluster.$(REDISTYPE).$$cid; \
	$(DOCKCMD) start redis-cluster.$(REDISTYPE).$$cid; \
	echo $(DOCKCMD) exec redis-cluster.$(REDISTYPE).$$cid ifconfig; \
	$(DOCKCMD) exec redis-cluster.$(REDISTYPE).$$cid ifconfig; \
	echo $(DOCKCMD) logs redis-cluster.$(REDISTYPE).$$cid; \
	$(DOCKCMD) logs redis-cluster.$(REDISTYPE).$$cid; \
	done

stop:
	$(DOCKCMD) run -d --rm $(VOLUMEOPT) --name $(CONTAINERCLUSTER) -h $(CONTAINERCLUSTER) --entrypoint $(REDISVOLUME)/bin/redis-cluster-trib.sh $(IMGNAME) save
	@for cid in $(CIDLIST);do \
	echo "==>redis-cluster.$(REDISTYPE).$$cid"; \
	echo $(DOCKCMD) stop redis-cluster.$(REDISTYPE).$$cid; \
	$(DOCKCMD) stop redis-cluster.$(REDISTYPE).$$cid; \
	echo $(DOCKCMD) wait redis-cluster.$(REDISTYPE).$$cid; \
	$(DOCKCMD) wait redis-cluster.$(REDISTYPE).$$cid; \
	done

bash:
	@for cid in $(CIDLIST);do \
	echo "==>redis-cluster.$(REDISTYPE).$$cid"; \
	echo $(DOCKCMD) exec -it redis-cluster.$(REDISTYPE).$$cid /bin/bash; \
	$(DOCKCMD) exec -it redis-cluster.$(REDISTYPE).$$cid /bin/bash; \
	break; \
	done

cli:
	@for cid in $(CIDLIST);do \
	echo "==>redis-cluster.$(REDISTYPE).$$cid"; \
	echo $(DOCKCMD) exec -it redis-cluster.$(REDISTYPE).$$cid /bin/bash $(REDISVOLUME)/bin/redis-cli.sh  $(REDISTYPE); \
	$(DOCKCMD) exec -it redis-cluster.$(REDISTYPE).$$cid /bin/bash $(REDISVOLUME)/bin/redis-cli.sh  $(REDISTYPE); \
	break; \
	done

clean:
	@for cid in $(CIDLIST);do \
	echo "==>redis-cluster.$(REDISTYPE).$$cid"; \
	echo $(DOCKCMD) container rm redis-cluster.$(REDISTYPE).$$cid; \
	$(DOCKCMD) container rm redis-cluster.$(REDISTYPE).$$cid; \
	done

cleandata:
	rm -rf ./$(VOLUMENAME)/$(REDISTYPE)/data/* ./$(VOLUMENAME)/$(REDISTYPE)/log/* 2>/dev/null

distclean:
	$(DOCKCMD) rmi $(IMGNAME)

clusterinfo:
	-cp /dev/null ./$(VOLUMENAME)/$(REDISTYPE)/data/redis-cluster.ip.port.all
	@for port in `cat ./$(VOLUMENAME)/$(REDISTYPE)/conf/redis-cluster.ports.all`; \
	do \
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



