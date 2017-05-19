#!/bin/sh
#set -x

CheckRedisType()
{
  if [ "x${1}" = 'xmq' ]; then
    shift
  elif [ "x${1}" = 'xdevinfo' ]; then
    shift
  elif [ "x${1}" = 'xsession' ]; then
    shift
  elif [ "x${1}" = 'xrating' ]; then
    shift
  elif [ "x${1}" = 'xratingcdr' ]; then
    shift
  elif [ "x${1}" = 'xdupcheck' ]; then
    shift
  elif [ "x${1}" = 'xautorule' ]; then
    shift
  else
    return 100
  fi
  return 0
}

GetAllRedisType()
{
  echo "mq devinfo session rating ratingcdr dupcheck autorule"
}

#redis客户端封装
REDIS_SELF()
{
    /redis/src/redis-cli $1 <<EOF
$2
quit
EOF
}


