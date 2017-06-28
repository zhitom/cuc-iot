FROM ubuntu:latest

MAINTAINER ZhiQiang Shan <shandyshandy@163.com>

# environment variables
ARG JSTORM_VERSION=2.2.1
ARG JSTORM_FILE=jstorm-${JSTORM_VERSION}.zip
ARG JSTORM_URL=https://github.com/alibaba/jstorm/releases/download/${JSTORM_VERSION}/${JSTORM_FILE}
ARG JSTORM_INSTALL_PATH=/opt
ENV JSTORM_HOME $JSTORM_INSTALL_PATH/jstorm
ENV JSTORM_CLUSTER  $JSTORM_HOME
ENV JSTORM_VERSION=2.2.1
ENV JRE_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre
ENV JAVA_HOME=${JRE_HOME}
ENV PATH $PATH:$JSTORM_CLUSTER/bin:$JSTORM_HOME/bin
ENV TERM xterm-color

#修改安装源
#RUN sed 's/archive.ubuntu.com/mirros.163.com/g' /etc/apt/sources.list > /etc/apt/sources.list.china
#RUN cp /etc/apt/sources.list /etc/apt/sources.list.ubuntu
#RUN cp /etc/apt/sources.list.china /etc/apt/sources.list

RUN ln -s ~/.profile ~/.bash_profile

#第3方软件
RUN apt-get update && \
    apt-get install -y vim net-tools iputils-ping

#安装：java unzip wget python jstorm
RUN apt-get update && \
    apt-get install -y openjdk-8-jre-headless unzip wget python && \
    apt-get clean && \
    mkdir -p "${JSTORM_INSTALL_PATH}" && \
    wget "$JSTORM_URL" -O "$JSTORM_INSTALL_PATH/$JSTORM_FILE" && \
    unzip "${JSTORM_INSTALL_PATH}/${JSTORM_FILE}" -d "${JSTORM_INSTALL_PATH}" && \
    mv "${JSTORM_INSTALL_PATH}/jstorm-${JSTORM_VERSION}" "${JSTORM_HOME}" && \
    mv "${JSTORM_HOME}/conf/storm.yaml" "${JSTORM_HOME}/conf/storm.yaml.template" && \
    chmod +x "$JSTORM_HOME/bin/jstorm" && \
    rm "$JSTORM_INSTALL_PATH/$JSTORM_FILE"


WORKDIR $JSTORM_HOME

# USER $JSTORM_USER
ADD build-data/jstorm.sh /
ADD build-data/common.sh /

ENTRYPOINT ["/jstorm.sh"]
