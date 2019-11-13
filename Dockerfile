FROM ubuntu:16.04

MAINTAINER bigbao <h_shibao@126.com>

USER root

RUN  sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN  apt-get clean
RUN  apt-get -y update
RUN  apt-get -y upgrade 
RUN  apt-get -y dist-upgrade --fix-missing
RUN  apt-get install -y openssh-server --fix-missing
RUN  apt-get install -y default-jdk --fix-missing
RUN  apt-get install -y wget --fix-missing
RUN  apt-get install -y scala --fix-missing
RUN  apt-get -y update --fix-missing
RUN  apt-get -y install zip --fix-missing
RUN  apt-get -y install vim --fix-missing
RUN  apt-get -y install net-tools
RUN  apt-get -y install netstat
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

RUN ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -P "" \
    && cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys

RUN wget -O /hadoop.tar.gz -q  https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz\
        && tar xfz hadoop.tar.gz \
        && mv /hadoop-3.2.1 /usr/local/hadoop \
        && rm /hadoop.tar.gz

RUN wget -O /spark.tar.gz -q https://mirrors.tuna.tsinghua.edu.cn/apache/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz
RUN tar xfz spark.tar.gz
RUN mv /spark-2.4.4-bin-hadoop2.7 /usr/local/spark
RUN rm /spark.tar.gz


ENV HADOOP_HOME=/usr/local/hadoop
ENV SPARK_HOME=/usr/local/spark
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$SPARK_HOME:sbin

RUN mkdir -p $HADOOP_HOME/hdfs/namenode \
        && mkdir -p $HADOOP_HOME/hdfs/datanode


COPY config/ /tmp/
RUN mv /tmp/ssh_config $HOME/.ssh/config \
    && mv /tmp/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
    && mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml \
    && mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml \
    && mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml.template \
    && cp $HADOOP_HOME/etc/hadoop/mapred-site.xml.template $HADOOP_HOME/etc/hadoop/mapred-site.xml \
    && mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml \
    && cp /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves \
    && mv /tmp/slaves $SPARK_HOME/conf/slaves \
    && mv /tmp/spark/spark-env.sh $SPARK_HOME/conf/spark-env.sh \
    && mv /tmp/spark/log4j.properties $SPARK_HOME/conf/log4j.properties \
    && mv /tmp/spark/spark.defaults.conf $SPARK_HOME/conf/spark.defaults.conf

ADD scripts/spark-services.sh $HADOOP_HOME/spark-services.sh

RUN chmod 744 -R $HADOOP_HOME


RUN $HADOOP_HOME/bin/hdfs namenode -format

EXPOSE 50010 50020 50070 50075 50090 8020 9000
EXPOSE 10020 19888
EXPOSE 8030 8031 8032 8033 8040 8042 8088
EXPOSE 49707 2122 7001 7002 7003 7004 7005 7006 7007 8888 9000

ENTRYPOINT service ssh start; cd $SPARK_HOME; bash


