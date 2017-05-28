#!/bin/sh

#Datastore
docker rmi rethinkdb

#Discovery
docker rmi microbox/etcd

#Proxy
docker rmi shipyard/docker-proxy

#Swarm Manager
docker rmi swarm

#Controller
docker rmi shipyard/shipyard

