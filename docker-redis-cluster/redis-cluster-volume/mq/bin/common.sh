#!/bin/sh
#set -x

CheckRedisType()
{
  redistype="mq devinfo session rating ratingcdr dupcheck autorule"
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
    echo "Please use correct redistype=${redistype}!"
    exit 100
  fi
}

#redis客户端封装
REDIS_SELF()
{
    /redis/src/redis-cli $1 <<EOF
$2
quit
EOF
}


