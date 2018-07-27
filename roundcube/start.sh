#!/bin/sh
# Настройка PHP-FPM
sed -i "s|;*daemonize\s*=\s*yes|daemonize = no|g" /etc/php5/php-fpm.conf && \
sed -i "s|;*listen\s*=\s*127.0.0.1:9000|listen = '/var/run/php5-fpm.socket'|g" /etc/php5/php-fpm.conf && \
#sed -i "s|;*listen\s*=\s*127.0.0.1:9000|listen = 127.0.0.1:9000|g" /etc/php5/php-fpm.conf && \
#sed -i "s|;*listen\s*=\s*/||g" /etc/php7/php-fpm.d/www.conf && \
sed -i "s|;*listen =.*|date.timezone = ${TIMEZONE}|i" /etc/php5/php.ini && \
sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" /etc/php5/php.ini && \
sed -i "s|;*memory_limit\s*=.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php5/php.ini && \
sed -i "s|.*upload_max_filesize\s*=.*|upload_max_filesize = ${MAX_UPLOAD}|g" /etc/php5/php.ini && \
sed -i "s|.*max_file_uploads\s*=.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|g" /etc/php5/php.ini && \
sed -i "s|.*post_max_size\s*=.*|post_max_size = ${PHP_MAX_POST}|g" /etc/php5/php.ini && \
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
sed -i "s|.*pm.max_children = 5.*|pm.max_children = ${FPM_MAX_CHILDREN}|g" /etc/php5/php-fpm.conf && \
sed -i "s|.*pm.start_servers = 2.*|pm.start_servers = ${FPM_START_SERVERS}|g" /etc/php5/php-fpm.conf && \
sed -i "s|.*pm.min_spare_servers = 1.*|pm.min_spare_servers = ${FPM_MIN_SPARE_SERVERS}|g" /etc/php5/php-fpm.conf && \
sed -i "s|.*pm.max_spare_servers = 3.*|pm.max_spare_servers = ${FPM_MAX_SPARE_SERVERS}|g" /etc/php5/php-fpm.conf && \

# SSL
sed -i '/server.modules = (/a\\    "mod_openssl",' /etc/lighttpd/lighttpd.conf && \
sed -i 's|.*ssl.engine.*|ssl.engine    = "enable"|g' /etc/lighttpd/lighttpd.conf && \
sed -i 's|.*ssl.pemfile\s*=.*|ssl.pemfile   = "/etc/lighttpd/server.pem"|g' /etc/lighttpd/lighttpd.conf && \

# Fix php warning
include = /etc/php5/fpm.d/*.conf
sed -i "s|.*include = /etc/php5/fpm.d/*.conf.*||g" /etc/php5/php-fpm.conf

# Запуск демонов
/usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf && /usr/bin/memcached -u memcached -d && /usr/bin/php-fpm5
#/usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf && /usr/bin/php-fpm5
