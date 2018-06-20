#!/bin/sh
#/usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf && /usr/bin/memcached -u memcached -d && /usr/sbin/php-fpm7
/usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf && /usr/sbin/php-fpm7