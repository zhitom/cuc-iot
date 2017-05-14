#CID_FILE = /tmp/grokzen-redis-cluster.cid
#CID =`cat $(CID_FILE)`
IMGNAME=zhitom/cuc-iot-redis-cluster-trib-mq:3.2.7
CONTAINERNAME=redis-cluster-trib-mq
CNAME=redis-cluster-mq
#多个的时候用空格分割
CIDLIST?="1"
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

copy:
	-cp /dev/null ./redis-cluster.ports.all
	@for cid in `echo $(CIDLIST)`; \
	do \
	echo ${CNAME}.$$cid ; \
	$(DOCKCMD) exec ${CNAME}.$$cid cat /redis-cluster-mq/conf/redis-cluster.ports >> ./redis-cluster.ports.all ; \
	done

run:copy
	$(DOCKCMD) run -d --rm --name $(CONTAINERNAME) -h $(CONTAINERNAME) $(IMGNAME)

start:run

stop:
	$(DOCKCMD) stop $(CONTAINERNAME)
	$(DOCKCMD) wait $(CONTAINERNAME)

bash:
	$(DOCKCMD) run -dit --rm --name $(CONTAINERNAME) -h $(CONTAINERNAME) $(IMGNAME) /bin/bash
	$(DOCKCMD) attach $(CONTAINERNAME) 
	-make stop
	
cli:
	@for cid in `echo $(CIDLIST)`; \
	do \
	echo ${CNAME}.$$cid ; \
	docker exec -it ${CNAME}.$$cid /bin/bash /redis-cli.sh ; \
	break; \
	done

clean:
	$(DOCKCMD) container rm $(CONTAINERNAME)

distclean:
	$(DOCKCMD) rmi $(IMGNAME)


