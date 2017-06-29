#!/bin/sh

. ./build-data/common.sh

OBJ=(zk jstorm)
DIR=(../docker-zookeeper-cluster .)
VOL=(zookeeper-cluster-volume jstorm-cluster-volume)
REVOBJ=$(eval "echo ${OBJ[@]}|awk '{for(i=NF;i>0;i--)print \$i;}'")
CLUSTERTYPE="$1";shift;

CheckClusterType $CLUSTERTYPE

if [ "x$1" = "x" ]; then
   echo Usage: $0 {`GetAllClusterType`} [${OBJ[@]}]
   exit 10
else
   for inobj in $*
   do
       isfound=0
       for obj in ${OBJ[@]}
       do
           if [ "x$obj" = "x$inobj" ]; then
	       isfound=1
	       break;
	   fi
        done
	if [ $isfound -eq 0 ]; then
	    echo "Incorrect arguments!"
	    echo Usage: $0 [${OBJ[@]}]
	    exit 11
	fi
    done
fi

stop()
{
  echo "$1==>stop from $2 ..."
  cd $2/
# docker-compose don't need stop
#  make CLUSTERTYPE=$CLUSTERTYPE stop
  make CLUSTERTYPE=$CLUSTERTYPE clean
  make CLUSTERTYPE=$CLUSTERTYPE NOCONFIRM=y cleandata cleanlog
  find $3/
  cd -
}

start()
{
  echo "$1==>start from $2 ..."
  cd $2
  make CLUSTERTYPE=$CLUSTERTYPE run
  cd -
}

echo REVOBJ=$REVOBJ deal_obj=$*

#stop with revobj
i=${#OBJ[@]}
let i=$i-1
for obj in $REVOBJ
do
    for inobj in $*
    do
        if [ "x${obj}" = "x${inobj}" ]; then
	    stop $obj ${DIR[$i]} ${VOL[$i]}
	fi
    done
    let i=$i-1
done

#start with obj
i=0
for obj in ${OBJ[@]}
do
    for inobj in $*
    do
        if [ "x${obj}" = "x${inobj}" ]; then
	    start $obj ${DIR[$i]}
	fi
    done
    let i=$i+1
done


