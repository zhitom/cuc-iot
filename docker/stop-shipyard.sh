#!/bin/sh

#Controller
docker stop shipyard-controller
docker rm shipyard-controller

#Swarm Agent
docker stop shipyard-swarm-agent
docker rm shipyard-swarm-agent

#Swarm Manager
docker stop shipyard-swarm-manager
docker rm shipyard-swarm-manager

#Proxy
docker stop shipyard-proxy
docker rm shipyard-proxy

#Discovery
docker stop shipyard-discovery
docker rm shipyard-discovery

#Datastore
docker stop shipyard-rethinkdb 
docker rm shipyard-rethinkdb



