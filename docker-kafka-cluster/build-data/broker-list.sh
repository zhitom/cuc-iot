#!/bin/bash

CONTAINERS=$(docker ps | grep $KAFKA_PORT | awk '{print $1}')
BROKERS=$(for CONTAINER in $CONTAINERS; do docker port $CONTAINER $2 | sed -e "s/0.0.0.0:/$HOST_IP:/g"; done)
echo $BROKERS | sed -e 's/ /,/g'

