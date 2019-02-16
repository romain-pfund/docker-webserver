FROM php:7.2-apache

LABEL MAINTAINER romain.pfund@rpinfo.ch

RUN apt-get update && apt-get install -y zlib1g-dev libpng-dev
RUN docker-php-ext-install pdo pdo_mysql gd zip

RUN usermod -u 1000 www-data

RUN a2enmod rewrite