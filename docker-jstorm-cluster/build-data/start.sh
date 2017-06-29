#!/usr/bin/env bash

if [ -e  ~/.bashrc ]
then
    source ~/.bashrc 1>/dev/null 2>/dev/null
fi

if [ -e  ~/.bash_profile ]
then
    source ~/.bash_profile 1>/dev/null 2>/dev/null
fi

if [ "x$JAVA_HOME" = "x" ]
then
#    echo "JAVA_HOME has been set " 
#else
    export JAVA_HOME=/opt/taobao/java
fi
echo "JAVA_HOME =" $JAVA_HOME

if [ "x$JSTORM_HOME" = "x" ]
then
#    echo "JSTORM_HOME has been set "
#else
    export JSTORM_HOME=/home/admin/jstorm
fi
echo "JSTORM_HOME =" $JSTORM_HOME

if [ "x$JSTORM_CONF_DIR" = "x" ]
then
#    echo "JSTORM_CONF_DIR has been set " 
#else
    export JSTORM_CONF_DIR=$JSTORM_HOME/conf
fi
echo "JSTORM_CONF_DIR =" $JSTORM_CONF_DIR
echo "JSTORM_CONF_FILE =" $JSTORM_CONF_DIR/storm.yaml

if [ "x$JSTORM_LOG_DIR" = "x" ]
then
#    echo "JSTORM_LOG_DIR has been set " 
#else
    export JSTORM_LOG_DIR=$JSTORM_HOME/logs
fi
mkdir -p ${JSTORM_LOG_DIR} 1>/dev/null 2>/dev/null
echo "JSTORM_LOG_DIR =" $JSTORM_LOG_DIR
export JSTORM_LOG_FILE=$JSTORM_LOG_DIR/jstorm-server.log
echo "JSTORM_LOG_FILE =" $JSTORM_LOG_FILE

export PATH=$JAVA_HOME/bin:$JSTORM_HOME/bin:$PATH


which java

if [ $? -eq 0 ]
then
    echo "Find java:`which java`"
else
    echo "No java, please install java firstly !!!"
    exit 1
fi

function startJStorm()
{
	PROCESS=$1
  echo "start $PROCESS ..."
  cd $JSTORM_HOME/bin; 
  cp -f /dev/null ${JSTORM_LOG_FILE} 1>/dev/null 2>/dev/null
  #nohup $JSTORM_HOME/bin/jstorm $PROCESS >/dev/null 2>&1 &
  nohup $JSTORM_HOME/bin/jstorm $PROCESS 1>>${JSTORM_LOG_FILE} 2>>${JSTORM_LOG_FILE} &
  tail -f ${JSTORM_LOG_FILE}
	#sleep 4
	#rm -rf nohup
	#ps -ef|grep $2
}

if [ "X${1}" = "Xnimbus" ]
then
    startJStorm "nimbus" "NimbusServer"
elif [ "X${1}" = "Xsupervisor" ]
then
    startJStorm "supervisor" "Supervisor"
elif [ "X${1}" = "Xnimbus-supervisor" ]
then
    startJStorm "nimbus" "NimbusServer"
    startJStorm "supervisor" "Supervisor"
else
    echo "Error  start jstorm daemon...."
    echo "need one param!"
    echo "usage: $0 [nimbus|supervisor|nimbus-supervisor]"
    echo "nimbus             start jstorm nimbus"
    echo "supervisor         start jstorm supervisor"
    echo "nimbus-supervisor  start jstorm nimbus and supervisor"
    exit 100;
fi

#HOSTNAME=`hostname -i`
#NIMBUS_HOST=`grep "nimbus.host:" $JSTORM_CONF_DIR/storm.yaml |grep -v "#" | grep -w $HOSTNAME`
#NIMBUS_HOST_START_SUPERVISOR=`grep "nimbus.host.start.supervisor:" $JSTORM_CONF_DIR/storm.yaml |grep -v "#" | grep -wi "false"`
#
#if [ "X${NIMBUS_HOST}" != "X" ]
#then
#	startJStorm "nimbus" "NimbusServer"
#fi
#
#if [ "X${NIMBUS_HOST}" != "X" ] && [ "X${NIMBUS_HOST_START_SUPERVISOR}" != "X" ]
#then
#	echo "Skip start Supervisor on nimbus host"
#else
#	startJStorm "supervisor" "Supervisor"
#fi

echo "jstorm already exit!"
