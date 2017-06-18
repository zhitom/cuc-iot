#!/bin/sh
#set -x

CheckClusterType()
{
  if [ "x${1}" = 'xf2m' ]; then
    shift
  elif [ "x${1}" = 'xm2f' ]; then
    shift
  else
    return 100
  fi
  return 0
}

GetAllClusterType()
{
  echo "f2m m2f"
}




