FROM hp:7.4-apache

LABEL MAINTAINER romain.pfund@rpinfo.ch

RUN mkdir -p /usr/src/php/ext/

RUN apt-get update --no-install-recommends -yqq && \
	apt-get install --no-install-recommends -yqq \
	zlib1g \
	cron \
	bzip2 \
	wget \
	nano
 
# Download & Install needed php extensions: ldap, imap, zlib, gd, soap
RUN apt-get install -y libz-dev && \
    curl -o zip.tgz -SL http://pecl.php.net/get/zip-1.15.1.tgz && \
        tar -xf zip.tgz -C /usr/src/php/ext/ && \
        rm zip.tgz && \
       	mv /usr/src/php/ext/zip-1.15.1 /usr/src/php/ext/zip && \
		docker-php-ext-install zip

RUN apt-get install --no-install-recommends -y libldap2-dev && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
	docker-php-ext-install ldap

RUN a2enmod rewrite expires

RUN apt-get install --no-install-recommends -yqq libssl-dev libc-client2007e-dev libkrb5-dev && \
    docker-php-ext-configure imap --with-imap-ssl --with-kerberos && \
    docker-php-ext-install imap

RUN apt-get install --no-install-recommends -yqq libbz2-dev && \
	docker-php-ext-install bz2

RUN apt-get install --no-install-recommends -yqq  re2c libmcrypt-dev libmcrypt4 libmcrypt-dev && \
    curl -o mcrypt.tgz -SL http://pecl.php.net/get/mcrypt-1.0.1.tgz && \
        tar -xf mcrypt.tgz -C /usr/src/php/ext/ && \
        rm mcrypt.tgz && \
        mv /usr/src/php/ext/mcrypt-1.0.1 /usr/src/php/ext/mcrypt && \
		docker-php-ext-install mcrypt

RUN apt-get --no-install-recommends -yqq  install zlib1g-dev && \
    docker-php-ext-install zip && \
    apt-get purge --auto-remove -y zlib1g-dev

RUN docker-php-ext-install mysqli

RUN docker-php-ext-install pdo pdo_mysql

RUN apt-get --no-install-recommends -yqq  install libxml2-dev && \
	docker-php-ext-install soap

RUN apt-get --no-install-recommends -yqq  install libxslt-dev && \
	docker-php-ext-install xmlrpc xsl

RUN curl -o apcu.tgz -SL http://pecl.php.net/get/apcu-5.1.9.tgz && \
	tar -xf apcu.tgz -C /usr/src/php/ext/ && \
	rm apcu.tgz && \
	mv /usr/src/php/ext/apcu-5.1.9 /usr/src/php/ext/apcu && \
	docker-php-ext-install apcu

RUN apt-get install --no-install-recommends --fix-missing -yqq libicu-dev libfreetype6-dev libpng-dev libpng16-16 libjpeg-dev libjpeg62-turbo-dev libzip-dev libwebp-dev  libxpm-dev && \
    docker-php-ext-configure gd --with-gd  --with-webp-dir --with-zlib-dir --with-xpm-dir  --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ --enable-gd-native-ttf  && \
	docker-php-ext-install gd

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN docker-php-ext-install opcache && \
	{ \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN usermod -u 1000 www-data

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
ENV COMPOSER_VERSION 1.8.4

RUN curl --silent --fail --location --retry 3 --output /tmp/installer.php --url https://raw.githubusercontent.com/composer/getcomposer.org/cb19f2aa3aeaa2006c0cd69a7ef011eb31463067/web/installer \
 && php -r " \
    \$signature = '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5'; \
    \$hash = hash('sha384', file_get_contents('/tmp/installer.php')); \
    if (!hash_equals(\$signature, \$hash)) { \
      unlink('/tmp/installer.php'); \
      echo 'Integrity check failed, installer is either corrupt or worse.' . PHP_EOL; \
      exit(1); \
    }" \
 && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
 && composer --ansi --version --no-interaction \
 && rm -f /tmp/installer.php
 
 RUN composer global require phpunit/phpunit ^7.0 --no-progress --no-scripts --no-interaction
 
  
