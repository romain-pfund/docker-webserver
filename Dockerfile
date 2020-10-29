FROM php:7.4-apache

LABEL MAINTAINER romain.pfund@rpinfo.ch

RUN mkdir -p /usr/src/php/ext/

# Installing Default packages
RUN apt-get update --no-install-recommends -yqq && \
	apt-get install --no-install-recommends -yqq \
	zlib1g \
	cron \
	bzip2 \
	wget \
	nano \
	curl
 
# Download & Install needed php extensions: ldap, imap, zlib, gd, soap,..

# ZIP Extension
RUN apt-get install -y libzip-dev && pecl install zip && docker-php-ext-enable zip

# LDAP
RUN apt-get install --no-install-recommends -y libldap2-dev && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
	docker-php-ext-install -j$(nproc) ldap

# IMAP
RUN apt-get install --no-install-recommends -yqq libssl-dev libc-client2007e-dev libkrb5-dev && \
    docker-php-ext-configure imap --with-imap-ssl --with-kerberos && \
    docker-php-ext-install -j$(nproc) imap
#
 BZ2
RUN apt-get install --no-install-recommends -yqq libbz2-dev && \
	docker-php-ext-install -j$(nproc) bz2

# MCRYPT
RUN apt-get install --no-install-recommends -yqq  re2c libmcrypt-dev libmcrypt4 libmcrypt-dev && \
	pecl install mcrypt && \
	docker-php-ext-enable mcrypt

# MYSQLI
RUN docker-php-ext-install -j$(nproc) mysqli

# PDO
RUN docker-php-ext-install -j$(nproc) pdo pdo_mysql

# SOAP
RUN apt-get --no-install-recommends -yqq  install libxml2-dev && \
	docker-php-ext-install -j$(nproc) soap

# XMLRPC CLS
RUN apt-get --no-install-recommends -yqq  install libxslt-dev && \
	docker-php-ext-install -j$(nproc) xmlrpc xsl

# APCU
RUN pecl install apcu && docker-php-ext-enable apcu

# GD
RUN apt-get install --no-install-recommends --fix-missing -yqq libicu-dev libfreetype6-dev libpng-dev libpng16-16 libjpeg-dev libjpeg62-turbo-dev libzip-dev libwebp-dev  libxpm-dev && \
    docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        -with-webp \
        --with-xpm && \
	docker-php-ext-install -j$(nproc) gd


# OPCACHE
# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN docker-php-ext-install -j$(nproc) opcache && \
	{ \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# PHP Unit
RUN composer global require phpunit/phpunit ^7.0 --no-progress --no-scripts --no-interaction

# Enable apache mod
RUN a2enmod rewrite expires

# User right
RUN usermod -u 1000 www-data