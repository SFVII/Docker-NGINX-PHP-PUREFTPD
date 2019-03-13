## Dockerfile pour le déploiement d'application de type wordpress
# ou plutot custom Website.

FROM phusion/baseimage:latest

MAINTAINER SFVII (brice@nippon.wtf)

ENV DEBIAN_FRONTEND noninteractive
ENV NGINX_HOST /etc/nginx/sites-available/default
ENV PHP_CONF /etc/php/7.0/fpm/php.ini
ENV PHP_FPM_SOCKET unix:/var/run/php/php7.0-fpm.sock
ENV NGINX_CONF /etc/nginx/nginx.conf
ENV NGINX_ERROR_LOG /var/log/nginx/error.log
ENV NGINX_ACCESS_LOG /var/log/nginx/access.log
ENV HTTP_PATH /var/www/web
ENV FTP_ROOT_PATH /var/www/
ENV FTP_NGINX_ERROR_LOG /var/www/log/error
ENV FTP_NGINX_ACCESS_LOG /var/www/log/access
ENV MEMCACHED_PORT 11211
ENV ENTRYPOINT /docker-entrypoint.sh

RUN add-apt-repository ppa:ondrej/php
RUN apt-get -y update
RUN apt-get -y --force-yes install dpkg-dev debhelper

#On va rajouter notre package liste au container
ADD packagelist.txt /tmp/packagelist.txt
RUN apt-get install --force-yes -y $(cat /tmp/packagelist.txt);

# On installe PureFTPD
ADD pureftpd.sh /tmp/pureftpd.sh
RUN chmod +x /tmp/pureftpd.sh
RUN /tmp/pureftpd.sh

# On Ajoute des templates
ADD browny-v1.0.zip /tmp/browny-v1.0.zip
RUN unzip /tmp/browny-v1.0.zip

#Erase default config
ADD site.conf /etc/nginx/sites-available/default
RUN mkdir /var/www/log/
RUN ln -s /var/log/nginx/error.log /var/www/log/.
RUN ln -s /var/log/nginx/access.log /var/www/log/.

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
