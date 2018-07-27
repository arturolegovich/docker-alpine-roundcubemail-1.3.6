# Use Alpine Linux
FROM alpine:latest

# Maintainer
#MAINTAINER Artur Petrov <artur@phpchain.ru>

# Переменные

# Часовой пояс
ENV TIMEZONE            Europe/Samara
# Объем памяти на один процесс PHP-FPM
ENV PHP_MEMORY_LIMIT    64M
# Максимальный размер загружаемого файла (вложение в письмо)
ENV MAX_UPLOAD          50M
# Количество одновременно загружаемых файлов
ENV PHP_MAX_FILE_UPLOAD 20
# Максимальный размер письма  вместе с вложением в письмо
ENV PHP_MAX_POST        51M
# Максимальное число создаваемых дочерних процессов (pm dynamic)
ENV FPM_MAX_CHILDREN 	20
# Число дочерних процессов, создаваемых при запуске (pm dynamic)
ENV FPM_START_SERVERS 	2
# Минимальное число неактивных дочерних процессов (pm dynamic)
ENV FPM_MIN_SPARE_SERVERS 1
# Максимальное число неактивных дочерних процессов сервера (pm dynamic)
ENV FPM_MAX_SPARE_SERVERS 10


# Добавляем скрипт автозапуска
#COPY start.sh /start.sh

# Добавляем сертификат сервера
COPY ssl/server.pem /etc/server.pem

# Добавляем roundcube-1.3.6 в образ
COPY roundcube /home/roundcube

# Дабавляем файл mime.types
ADD http://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types /home/roundcube/

# Добавляем php_imagick
COPY imagick-3.4.3 /imagick-3.4.3-src

# Добавляем php_memcache
COPY memcache-3.0.8 /memcache-3.0.8-src

# Установка небходимого программного обеспечения
RUN     echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/main" >> /etc/apk/repositories && \
    apk update && \
    apk upgrade && \
#    apk add --upgrade apk-tools@edge \
    apk add --update tzdata && \
    cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone && \
    apk add --update \
# Dev-utils
	autoconf \
	automake \
	make \
	php5-dev \
	gcc \
	g++ \
	libtool \
	imagemagick \
	imagemagick-dev \
	memcached \
	zlib \
	zlib-dev \
	file \
	lighttpd \
#	memcached \
        php5-mcrypt \
#        php5-session \
        php5-sockets \
#        php5-mbstring \
#       php5-soap \
        php5-openssl \
#       php5-gmp \
#       php5-pdo_odbc \
        php5-json \
        php5-dom \
        php5-pdo \
        php5-zip \
#       php5-mysqli \
#       php5-sqlite3 \
#       php5-pdo_pgsql \
#       php5-bcmath \
#       php5-odbc \
        php5-pdo_mysql \
#       php5-pdo_sqlite \
#       php5-gettext \
	php5-xml \
#	php5-xmlreader \
#	php5-xmlrpc \
#       php5-bz2 \
#       php5-pdo_dblib \
#       php5-curl \
#       php5-ctype \
#	php5-memcached \
# Доп пакеты
#	php5-fileinfo \
	php5-iconv \
	php5-intl \
	php5-exif \
	php5-ldap \
        php5-gd \
#        php5-imagick \
# Кэширование в PHP5
	php5-opcache \
# PHP-FPM
        php5-fpm && \

# Настройка PHP-FPM
sed -i "s|;*daemonize\s*=\s*yes|daemonize = no|g" /etc/php5/php-fpm.conf && \
sed -i "s|;*listen\s*=\s*127.0.0.1:9000|listen = '/var/run/php5-fpm.socket'|g" /etc/php5/php-fpm.conf && \
sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo= 0|i" /etc/php5/php.ini && \

# php5-memcache
sed -i 's|.*session.save_handler.*|session.save_handler = memcache|g' /etc/php5/php.ini && \
sed -i 's|.*;session.save_path = "/tmp".*|session.save_path = tcp://127.0.0.1:11211|g' /etc/php5/php.ini && \

# Настройка lighttpd
sed -i 's|.*mod_fastcgi_fpm.conf.*|include "mod_fastcgi_fpm.conf"|g' /etc/lighttpd/lighttpd.conf && \
sed -i 's|.*var.basedir\s*=.*|var.basedir = "/home/roundcube"|g' /etc/lighttpd/lighttpd.conf && \
sed -i "s|.*server.document-root\s*=.*|server.document-root = var.basedir|g" /etc/lighttpd/lighttpd.conf && \

# Настройка mod_fastcgi_fpm на использование php5-fpm.socket
sed -i 's|.*"host".*|                           "socket"=>"/var/run/php5-fpm.socket"|g' /etc/lighttpd/mod_fastcgi_fpm.conf && \
sed -i 's|.*"port".*||g' /etc/lighttpd/mod_fastcgi_fpm.conf && \
sed -i 's|.*listen.owner = nobody.*|listen.owner = lighttpd|g' /etc/php5/php-fpm.conf && \
sed -i 's|.*listen.group = nobody.*|listen.group = lighttpd|g' /etc/php5/php-fpm.conf && \

# SSL
sed -i '/server.modules = (/a\\    "mod_openssl",' /etc/lighttpd/lighttpd.conf && \
sed -i 's|.*ssl.engine.*|ssl.engine    = "enable"|g' /etc/lighttpd/lighttpd.conf && \
sed -i 's|.*ssl.pemfile\s*=.*|ssl.pemfile   = "/etc/lighttpd/server.pem"|g' /etc/lighttpd/lighttpd.conf && \

# Fix php warning
sed -i "s|.*include\s*=.*||g" /etc/php5/php-fpm.conf && \

chmod a+x /home/roundcube/start.sh && \

# Меняем права на файлы и каталоги roundcube
chmod -R 777 /home/roundcube/temp /home/roundcube/logs && \
chmod 644 /home/roundcube/mime.types && \

# Меняем права доступа на файл сертификата
mv /etc/server.pem /etc/lighttpd/server.pem && \
chown lighttpd:lighttpd /etc/lighttpd/server.pem && \
chmod 400 /etc/lighttpd/server.pem && \

# Сборка php_imagick из исходного кода
cd /imagick-3.4.3-src && \
phpize5 && \
./configure --with-php-config=/usr/bin/php-config5 && \
make && \
make install && \
make clean && \
echo "extension=imagick.so" > /etc/php5/conf.d/imagick.ini && \

# Сборка php_memcache из исходного кода
cd /memcache-3.0.8-src && \
phpize5 && \
./configure --with-php-config=/usr/bin/php-config5 --with-zlib-dir=/usr && \
make && \
make install && \
make clean && \
echo "extension=memcache.so" > /etc/php5/conf.d/memcache.ini && \

# Очистка системы от послеустановочного мусора
apk del tzdata automake make gcc g++ autoconf libtool php5-dev imagemagick-dev file zlib-dev && \
rm -rf /imagick-3.4.3-src && \
rm -rf /memcache-3.0.8-src && \
rm -rf /usr/bin/phpize && \
rm -rf /var/cache/apk/*

# Set Workdir
WORKDIR /home/roundcube

# Expose volumes
VOLUME ["/home/roundcube/config/"]

# Expose ports
EXPOSE 443/tcp

# Entry point
ENTRYPOINT ["/home/roundcube/start.sh"]
