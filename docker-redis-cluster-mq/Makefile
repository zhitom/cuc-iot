#CID_FILE = /tmp/grokzen-redis-cluster.cid
#CID =`cat $(CID_FILE)`
#下面的根据本机情况进行修改
REDISVOLUME=/redis-cluster-mq
VOLUMENAME=/d/opensoft/dockers/cuc-iot-dockers/docker-redis-cluster-mq/redis-cluster-volume
IMGNAME=cuc-iot/redis-cluster-mq:3.2.7
CONTAINERNAME=redis-cluster-mq
CONTAINERID?=1
DOCKCMD=docker

help:
	@echo "rebuild  	rebuild image"
	@echo "run      	run image to new container"
	@echo "start    	start container"
	@echo "stop     	stop container"
	@echo "bash      	start bash with current container"
	@echo "cli    	 	start redis-cli using first redis-ip:port with current container"
	@echo "clean    	delete container"
	@echo "distclean 	delete image"

rebuild:
	$(DOCKCMD) build --no-cache=true -t $(IMGNAME) .

run:
	$(DOCKCMD) run -d -v $(VOLUMENAME)/data:$(REDISVOLUME)/data -v $(VOLUMENAME)/log:$(REDISVOLUME)/log --name $(CONTAINERNAME).$(CONTAINERID) -h $(CONTAINERNAME).$(CONTAINERID) $(IMGNAME)
	$(DOCKCMD) exec $(CONTAINERNAME).$(CONTAINERID) ifconfig
	$(DOCKCMD) logs $(CONTAINERNAME).$(CONTAINERID)

start:
	$(DOCKCMD) start $(CONTAINERNAME).$(CONTAINERID)
	$(DOCKCMD) exec $(CONTAINERNAME).$(CONTAINERID) ifconfig
	$(DOCKCMD) logs $(CONTAINERNAME).$(CONTAINERID)

stop:
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


