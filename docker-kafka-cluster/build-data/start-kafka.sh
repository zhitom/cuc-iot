#!/bin/bash

#设置环境变量
if [[ -z "$KAFKA_PORT" ]]; then
    export KAFKA_PORT=9092
fi
#if [[ -z "$KAFKA_ADVERTISED_PORT" && \
#  -z "$KAFKA_LISTENERS" && \
#  -z "$KAFKA_ADVERTISED_LISTENERS" ]]; then
#    export KAFKA_ADVERTISED_PORT=$(docker port `hostname` $KAFKA_PORT | sed -r "s/.*:(.*)/\1/g")
#fi
if [[ -z "$KAFKA_BROKER_ID" ]]; then
    if [[ -n "$BROKER_ID_COMMAND" ]]; then
        export KAFKA_BROKER_ID=$(eval $BROKER_ID_COMMAND)
    else
        # By default auto allocate broker ID
        export KAFKA_BROKER_ID=-1
    fi
fi
if [[ -z "$KAFKA_LOG_DIRS" ]]; then
    export KAFKA_LOG_DIRS="/kafka/kafka-logs-$HOSTNAME"
fi
if [[ -z "$KAFKA_ZOOKEEPER_CONNECT" ]]; then
    export KAFKA_ZOOKEEPER_CONNECT=$(env | grep ZK.*PORT_2181_TCP= | sed -e 's|.*tcp://||' | paste -sd ,)
fi

if [[ -n "$KAFKA_HEAP_OPTS" ]]; then
    sed -r -i "s/(export KAFKA_HEAP_OPTS)=\"(.*)\"/\1=\"$KAFKA_HEAP_OPTS\"/g" $KAFKA_HOME/bin/kafka-server-start.sh
    unset KAFKA_HEAP_OPTS
fi

if [[ -z "$KAFKA_ADVERTISED_HOST_NAME" && -n "$HOSTNAME_COMMAND" ]]; then
    export KAFKA_ADVERTISED_HOST_NAME=$(eval $HOSTNAME_COMMAND)
fi

if [[ -z "$KAFKA_HOST_NAME" ]]; then
    export KAFKA_HOST_NAME=${KAFKA_ADVERTISED_HOST_NAME}
fi

if [[ -z "$KAFKA_ADVERTISED_HOST_NAME" ]]; then
    #export KAFKA_ADVERTISED_HOST_NAME=$(eval "ifconfig eth0|grep -w -i 'inet addr'|awk -F: '{print \$2}'|awk '{print \$1}'")
    export KAFKA_ADVERTISED_HOST_NAME=$(eval "hostname")
fi

if [[ -z "$KAFKA_ADVERTISED_LISTENERS" ]]; then
    export KAFKA_ADVERTISED_LISTENERS="PLAINTEXT://${KAFKA_ADVERTISED_HOST_NAME}:${KAFKA_ADVERTISED_PORT}"
    unset KAFKA_ADVERTISED_HOST_NAME
    unset KAFKA_ADVERTISED_PORT
    echo KAFKA_ADVERTISED_LISTENERS="${KAFKA_ADVERTISED_LISTENERS}"
fi

#处理命令
if [ "x$1" = "xstart" ]; then
    shift
    for VAR in `env`
    do
      echo "ENV_VAR:$VAR=${!env_var}"
      if [[ $VAR =~ ^KAFKA_ && ! $VAR =~ ^KAFKA_HOME ]]; then
        kafka_name=`echo "$VAR" | sed -r "s/KAFKA_(.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr _ .`
        env_var=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g"`
        if egrep -q "(^|^#)$kafka_name=" $KAFKA_HOME/config/server.properties; then
            sed -r -i "s@(^|^#)($kafka_name)=(.*)@\2=${!env_var}@g" $KAFKA_HOME/config/server.properties #note that no config values may contain an '@' char
        else
            echo "$kafka_name=${!env_var}" >> $KAFKA_HOME/config/server.properties
        fi
      fi
    done

    if [[ -n "$CUSTOM_INIT_SCRIPT" ]] ; then
      eval $CUSTOM_INIT_SCRIPT
    fi
    #tail -f /kafka-cluster/f2m/bin/start-kafka.sh
    if [ "x$1" != "x" ]; then
        echo $$ > $1
    fi
    exec $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
    exit 0
else
    #根据环境变量创建预定义的主题
    #预定义的主题：topic:partitions:replicas:cleanup.policy
    #cleanup.policy=delete(直接删除),compact(同一个key压缩合并，仅保留最新版本数据)
    #create_topics()
    #{
    #    #set -x
    #    if [[ -z "$START_TIMEOUT" ]]; then
    #        START_TIMEOUT=600
    #    fi
    #
    #    start_timeout_exceeded=false
    #    count=0
    #    step=10
    #    while netstat -lnt | awk '$4 ~ /:'$KAFKA_PORT'$/ {exit 1}'; do
    #        echo "waiting for kafka to be ready"
    #        sleep $step;
    #        count=$(expr $count + $step)
    #        if [ $count -gt $START_TIMEOUT ]; then
    #            start_timeout_exceeded=true
    #            break
    #        fi
    #    done
    #
    #    if $start_timeout_exceeded; then
    #        echo "Not able to auto-create topic (waited for $START_TIMEOUT sec)"
    #        exit 111
    #    fi
    #
    #    if [[ -n $KAFKA_CREATE_TOPICS ]]; then
    #        IFS=','; for topicToCreate in $KAFKA_CREATE_TOPICS; do
    #            echo "creating topics: $topicToCreate"
    #            IFS=':' read -a topicConfig <<< "$topicToCreate"
    #            if [ ${topicConfig[3]} ]; then
    #              JMX_PORT='' $KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper $KAFKA_ZOOKEEPER_CONNECT --replication-factor ${topicConfig[2]} --partition ${topicConfig[1]} --topic "${
    #    topicConfig[0]}" --config cleanup.policy="${topicConfig[3]}"
    #            else
    #              JMX_PORT='' $KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper $KAFKA_ZOOKEEPER_CONNECT --replication-factor ${topicConfig[2]} --partition ${topicConfig[1]} --topic "${
    #    topicConfig[0]}"
    #            fi
    #        done
    #    fi
    #}

    create-topics.sh 
    #create_topics
fi

