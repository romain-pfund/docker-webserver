FROM ubuntu:bionic

LABEL MAINTAINER romain.pfund@rpinfo.ch


RUN apt-get update --no-install-recommends -yqq && \
	apt-get install --no-install-recommends -yqq \
	curl \
	zlib1g \
	cron \
	bzip2 \
	wget \
	vim \
	nano

RUN wget -O- http://rpms.litespeedtech.com/debian/enable_lst_debian_repo.sh | /bin/bash && \
     apt-get update --no-install-recommends -yqq && \
     apt-get install -y openlitespeed

RUN apt-get install -y lsphp73 lsphp73-common lsphp73-opcache lsphp73-curl lsphp73-imagick lsphp73-imap lsphp73-json lsphp73-memcached lsphp73-mysql


RUN mkdir -p /usr/local/lsws/Website/html/
COPY october/. /usr/local/lsws/Website/html/
RUN chown -R nobody:nogroup /usr/local/lsws/Website && chmod -R 755 /usr/local/lsws/Website

COPY ./litespeed/conf/. /usr/local/lsws/conf/

RUN rm -rf /usr/local/lsws/Example && rm -rf /usr/local/lsws/conf/vhosts/Example


ENV PATH="/usr/local/lsws/bin/:${PATH}"

CMD ["bash", "-c", "/usr/local/lsws/bin/lswsctrl start; tail -f /dev/null"]