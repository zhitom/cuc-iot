#CID_FILE = /tmp/grokzen-redis-cluster.cid
#CID =`cat $(CID_FILE)`
#下面的根据本机情况进行修改
#容器里边的路径
REDISVOLUME=/redis-cluster-mq
#虚拟机或本机里边的路径
VOLUMENAME=/redis-cluster-volume
#windows下面的mingw下的路径，使mingw下的make命令可以访问，如果是linux，将WINVOLUMEPATH和VOLUMENAME设置为一致即可
WINVOLUMEPATH=/d/weiyun/mygit/cuc-iot/docker-redis-cluster-mq/redis-cluster-volume
#window下，建议使用host模式，支持双向访问，否则只能容器访问外面IP，不能外面访问容器IP
HOSTOPT=--net=host
IMGNAME=zhitom/cuc-iot-redis-cluster-mq:latest
CONTAINERNAME=redis-cluster-mq
CONTAINERID?=1
DOCKCMD=docker
#多个的时候用空格分割
CIDLIST?="1"
TRIBPARAM?=redis-cluster-mq

help:
	@echo "rebuild  	rebuild image"
	@echo "run      	run image to new container"
	@echo "start    	start container"
	@echo "stop     	stop container"
	@echo "bash      	start bash with current container"
	@echo "cli    	 	start redis-cli using first redis-ip:port with current container"
	@echo "clean    	delete container"
	@echo "distclean 	delete image"
	@echo "cluster   	create cluster,only once!"

rebuild:
	$(DOCKCMD) build --no-cache=true -t $(IMGNAME) .

run:
	$(DOCKCMD) run $(HOSTOPT) -d $(shell for p in `$(DOCKCMD) image inspect --format='{{range $$p, $$conf := .Config.ExposedPorts}} {{$$p}} {{end}}' $(IMGNAME)|sed 's/\/tcp//g'`;do \
					CLIENTPORT="$${CLIENTPORT} -p $$p:$$p"; \
					done&&echo $${CLIENTPORT}) \
					-v $(VOLUMENAME)/data:$(REDISVOLUME)/data \
					-v $(VOLUMENAME)/log:$(REDISVOLUME)/log \
					--name $(CONTAINERNAME).$(CONTAINERID) \
					-h $(CONTAINERNAME).$(CONTAINERID) $(IMGNAME)
	$(DOCKCMD) exec $(CONTAINERNAME).$(CONTAINERID) ifconfig
	$(DOCKCMD) logs $(CONTAINERNAME).$(CONTAINERID)
	$(DOCKCMD) port $(CONTAINERNAME).$(CONTAINERID)

runbak:
	$(DOCKCMD) run $(HOSTOPT) -d \
					-v $(VOLUMENAME)/data:$(REDISVOLUME)/data \
					-v $(VOLUMENAME)/log:$(REDISVOLUME)/log \
					--name $(CONTAINERNAME).$(CONTAINERID) \
					-h $(CONTAINERNAME).$(CONTAINERID) $(IMGNAME)
	$(DOCKCMD) exec $(CONTAINERNAME).$(CONTAINERID) ifconfig
	$(DOCKCMD) logs $(CONTAINERNAME).$(CONTAINERID)
	$(DOCKCMD) port $(CONTAINERNAME).$(CONTAINERID)

start:
	$(DOCKCMD) start $(CONTAINERNAME).$(CONTAINERID)
	$(DOCKCMD) exec $(CONTAINERNAME).$(CONTAINERID) ifconfig
	$(DOCKCMD) logs $(CONTAINERNAME).$(CONTAINERID)

stop:
	$(DOCKCMD) run -d --rm --name $(CONTAINERNAME).cluster -h $(CONTAINERNAME).cluster --entrypoint /redis-cluster-mq/redis-cluster-trib.sh $(IMGNAME) save
	$(DOCKCMD) wait $(CONTAINERNAME).cluster
	$(DOCKCMD) stop $(CONTAINERNAME).$(CONTAINERID)
	$(DOCKCMD) wait $(CONTAINERNAME).$(CONTAINERID)

bash:
	$(DOCKCMD) exec -it $(CONTAINERNAME).$(CONTAINERID) /bin/bash

cli:
	$(DOCKCMD) exec -it $(CONTAINERNAME).$(CONTAINERID) /bin/bash /redis-cli.sh

clean:
	$(DOCKCMD) container rm $(CONTAINERNAME).$(CONTAINERID)

distclean:
	$(DOCKCMD) rmi $(IMGNAME)

clusterinfo:
	-cp /dev/null ./docker-data/redis-cluster.ports.all
	@for cid in `echo $(CIDLIST)`; \
	do \
	echo get ip:port from ${CONTAINERNAME}.$$cid ; \
	$(DOCKCMD) exec ${CONTAINERNAME}.$$cid cat /redis-cluster-mq/conf/redis-cluster.ports >> ./docker-data/redis-cluster.ports.all ; \
	done

cluster:clusterinfo
	@echo "run new container for redis-cluster's creating..."
	$(DOCKCMD) run -d --rm --name $(CONTAINERNAME).cluster -h $(CONTAINERNAME).cluster --entrypoint /redis-cluster-mq/redis-cluster-trib.sh $(IMGNAME) initialize
	@for cid in `cat ./docker-data/redis-cluster.ports.all`; \
	do \
	echo instance ${CONTAINERNAME}.$$cid: /redis-cluster-mq/redis-cluster-trib.sh append $$cid "..." ; \
	$(DOCKCMD) exec -it $(CONTAINERNAME).cluster /redis-cluster-mq/redis-cluster-trib.sh append $$cid; \
	done
	@echo "/redis-cluster-mq/redis-cluster-trib.sh ${TRIBPARAM} ..."
	$(DOCKCMD) exec -it $(CONTAINERNAME).cluster /redis-cluster-mq/redis-cluster-trib.sh ${TRIBPARAM}
	@echo "stop and clean this container..."
	$(DOCKCMD) stop $(CONTAINERNAME).cluster



