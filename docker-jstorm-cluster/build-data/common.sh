#!/bin/sh
#set -x

ALLCLUSTTYPES="offline cb autorule infomgr acctout"

CheckClusterType()
{
  for t in ${ALLCLUSTTYPES}
  do
       if [ "x$t" = "x${1}" ]; then
          shift;
          return 0
       fi
  done
  return 100
}

GetAllClusterType()
{
  echo ${ALLCLUSTTYPES}
}




