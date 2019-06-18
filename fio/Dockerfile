FROM ubuntu

MAINTAINER Support support@diamanti.com

RUN apt-get update -yq && apt-get install -yq fio

RUN mkdir /data 
RUN mkdir /config 
RUN mkdir /state

ADD start.sh /start.sh

RUN chmod 777 /start.sh

ENTRYPOINT ["./start.sh"]
