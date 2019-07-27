FROM phpearth/php:7.4-lighttpd

LABEL MAINTAINER romain.pfund@rpinfo.ch

RUN apk add --no-cache composer


RUN apk add --no-cache php7.4-zip php7.4-ldap  php7.4-imap php7.4-bz2  php7.4-pdo_mysql
