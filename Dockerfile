# Use Alpine Linux
FROM alpine:latest

# Maintainer
#MAINTAINER Artur Petrov <artur@phpchain.ru>

# Переменные

# Часовой пояс
ENV TIMEZONE            Europe/Samara
# Объем памяти на один процесс PHP-FPM
ENV PHP_MEMORY_LIMIT    256M
# Максимальный размер загружаемого файла (вложение в письмо)
ENV MAX_UPLOAD          50M
# Количество одновременно загружаемых файлов
ENV PHP_MAX_FILE_UPLOAD 20
# Максимальный размер письма  вместе с вложением в письмо
ENV PHP_MAX_POST        51M

# Добавляем скрипт автозапуска
#COPY start.sh /start.sh

# Добавляем сертификат сервера
COPY ssl/server.pem /etc/server.pem

# Добавляем roundcube-1.3.6 в образ
COPY roundcube /home/roundcube

# Дабавляем файл mime.types
ADD http://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types /home/roundcube/

# Установка небходимого программного обеспечения
RUN     echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/main" >> /etc/apk/repositories && \
    apk update && \
    apk upgrade && \
    apk add --update tzdata && \
    cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone && \
    apk add --update \
	lighttpd \
        php7-mcrypt \
        php7-session \
        php7-sockets \
        php7-mbstring \
#       php7-soap \
        php7-openssl \
#       php7-gmp \
#       php7-pdo_odbc \
        php7-json \
        php7-dom \
        php7-pdo \
        php7-zip \
#       php7-mysqli \
#       php7-sqlite3 \
#       php7-pdo_pgsql \
#       php7-bcmath \
#       php7-odbc \
        php7-pdo_mysql \
#       php7-pdo_sqlite \
#       php7-gettext \
	php7-xml \
#	php7-xmlreader \
#	php7-xmlrpc \
#       php7-bz2 \
#       php7-pdo_dblib \
#       php7-curl \
#       php7-ctype \
# Доп пакеты
	php7-fileinfo \
	php7-iconv \
	php7-intl \
	php7-exif \
	php7-ldap \
        php7-gd \
        php7-imagick \
# PHP-FPM
        php7-fpm && \

# Настройка PHP-FPM
sed -i "s|;*daemonize\s*=\s*yes|daemonize = no|g" /etc/php7/php-fpm.conf && \
#sed -i "s|;*listen\s*=\s*127.0.0.1:9000|listen = '/var/run/php7-fpm.socket'|g" /etc/php7/php-fpm.d/www.conf && \
sed -i "s|;*listen\s*=\s*127.0.0.1:9000|listen = 127.0.0.1:9000|g" /etc/php7/php-fpm.d/www.conf && \
sed -i "s|;*listen\s*=\s*/||g" /etc/php7/php-fpm.d/www.conf && \
sed -i "s|;*listen =.*|date.timezone = ${TIMEZONE}|i" /etc/php7/php.ini && \
sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" /etc/php7/php.ini && \
sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php7/php.ini && \
sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|i" /etc/php7/php.ini && \
sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php7/php.ini && \
sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" /etc/php7/php.ini && \
sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo= 0|i" /etc/php7/php.ini && \

# Настройка lighttpd
sed -i 's|.*mod_fastcgi_fpm.conf.*|include "mod_fastcgi_fpm.conf"|g' /etc/lighttpd/lighttpd.conf && \
sed -i 's|.*var.basedir\s*=.*|var.basedir = "/home/roundcube"|g' /etc/lighttpd/lighttpd.conf && \
sed -i "s|.*server.document-root\s*=.*|server.document-root = var.basedir|g" /etc/lighttpd/lighttpd.conf && \

# SSL
sed -i '/server.modules = (/a\\    "mod_openssl",' /etc/lighttpd/lighttpd.conf && \
sed -i 's|.*ssl.engine.*|ssl.engine    = "enable"|g' /etc/lighttpd/lighttpd.conf && \
sed -i 's|.*ssl.pemfile\s*=.*|ssl.pemfile   = "/etc/lighttpd/server.pem"|g' /etc/lighttpd/lighttpd.conf && \

chmod a+x /home/roundcube/start.sh && \

# Меняем права на файлы и каталоги roundcube
chmod -R 777 /home/roundcube/temp /home/roundcube/logs && \
chmod 644 /home/roundcube/mime.types && \

# Меняем права доступа на файл сертификата
mv /etc/server.pem /etc/lighttpd/server.pem && \
chown lighttpd:lighttpd /etc/lighttpd/server.pem && \
chmod 400 /etc/lighttpd/server.pem && \

# Очистка системы от послеустановочного мусора
apk del tzdata && \
rm -rf /var/cache/apk/*

# Set Workdir
WORKDIR /home/roundcube

# Expose volumes
VOLUME ["/home/roundcube/config/"]

# Expose ports
EXPOSE 80/tcp 443/tcp

# Entry point
#ENTRYPOINT ["/usr/sbin/php-fpm7"]
#CMD ["/start.sh"]
ENTRYPOINT ["/home/roundcube/start.sh"]
