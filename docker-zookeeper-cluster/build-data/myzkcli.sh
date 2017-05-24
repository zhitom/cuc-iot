#!/bin/sh
echo PATH=$PATH
HNAME=${HOSTNAME}
if [ "x${HNAME}" = "x" ]; then
    #ip=`grep -w ${HNAME} /etc/hosts|awk '{print $1}'`
    HNAME=`hostname`;
fi
echo zkCli.sh -server ${HNAME}:${ZOO_PORT} $@
zkCli.sh -server ${HNAME}:${ZOO_PORT} $@

