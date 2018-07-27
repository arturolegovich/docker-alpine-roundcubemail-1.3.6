#!/bin/sh
# Настройка PHP-FPM
sed -i "s|;*listen =.*|date.timezone = ${TIMEZONE}|i" /etc/php5/php.ini && \
sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" /etc/php5/php.ini && \
sed -i "s|;*memory_limit\s*=.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php5/php.ini && \
sed -i "s|.*upload_max_filesize\s*=.*|upload_max_filesize = ${MAX_UPLOAD}|g" /etc/php5/php.ini && \
sed -i "s|.*max_file_uploads\s*=.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|g" /etc/php5/php.ini && \
sed -i "s|.*post_max_size\s*=.*|post_max_size = ${PHP_MAX_POST}|g" /etc/php5/php.ini && \
# Настройка mod_fastcgi_fpm на использование php5-fpm.socket
sed -i "s|.*pm.max_children = 5.*|pm.max_children = ${FPM_MAX_CHILDREN}|g" /etc/php5/php-fpm.conf && \
sed -i "s|.*pm.start_servers = 2.*|pm.start_servers = ${FPM_START_SERVERS}|g" /etc/php5/php-fpm.conf && \
sed -i "s|.*pm.min_spare_servers = 1.*|pm.min_spare_servers = ${FPM_MIN_SPARE_SERVERS}|g" /etc/php5/php-fpm.conf && \
sed -i "s|.*pm.max_spare_servers = 3.*|pm.max_spare_servers = ${FPM_MAX_SPARE_SERVERS}|g" /etc/php5/php-fpm.conf  > /dev/null 2>&1
# Запуск демонов
/usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf && /usr/bin/memcached -u memcached -d && /usr/bin/php-fpm5
