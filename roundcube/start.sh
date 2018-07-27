#!/bin/sh
/usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf && /usr/bin/memcached -u memcached -d && /usr/bin/php-fpm5
#/usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf && /usr/bin/php-fpm5
