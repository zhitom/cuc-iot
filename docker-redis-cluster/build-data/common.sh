#!/bin/sh
#set -x

ALLCLUSTTYPES="mq devinfo session rating ratingcdr dupcheck autorule param"


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

#redis客户端封装
REDIS_SELF()
{
    REDISCLI="$1";shift;
    ${REDISCLI} $1 <<EOF
$2
quit
EOF
}


