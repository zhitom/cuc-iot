#!/bin/sh

make stop 
make clean
make NOCONFIRM=y cleandata cleanlog

cd ../docker-zookeeper-cluster;
make stop 
make clean
make NOCONFIRM=y cleandata cleanlog
make run

cd -
make run

