# docker-webserver

Apache + PHP 7.2

Apache:
rewrite mod enable

PHP:
pdo pdo_mysql gd zip


# test and copy litespeed config
docker run -it --rm --name litespeed -v C:\Users\romai\Documents\docker\testLitespeed:/usr/local/lsws/Example/html -w /usr/local/lsws -p 80:80 -p 7080:7080 -d litespeed


docker cp litespeed:/usr/local/lsws/conf/httpd_config.conf C:\Users\romai\Documents\docker\docker-webserver\litespeed