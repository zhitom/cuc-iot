#!/bin/sh

. ./build-data/common.sh

OBJ=(zk)
DIR=(.)
VOL=(zookeeper-cluster-volume)
REVOBJ=$(eval "echo ${OBJ[@]}|awk '{for(i=NF;i>0;i--)print \$i;}'")
RESTARTTYPE="$1";
if [ "x$1" != "x" ]; then
    shift
fi
CLUSTERTYPE="$1";
if [ "x$1" != "x" ]; then
    shift
fi

CheckClusterType $CLUSTERTYPE

if [ "x$1" = "x" ]; then
   echo Usage: $0 "{all|start|stop}" {`GetAllClusterType`} [${OBJ[@]}]
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
if [ "x$RESTARTTYPE" != "xstart" ]; then
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
fi

#start with obj
if [ "x$RESTARTTYPE" != "xstop" ]; then
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
fi

