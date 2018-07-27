# Docker alpine roundcubemail 1.3.6 with php7-fpm imagemagick-7

## Описание

Вашему вниманию представлены исходные кода для создания полноценного docker-образа roundcubemail-1.3.6.
За основу взят образ alpine:latest.
Образ включает в себя следующее программное обеспечение:
```
lighttpd(SSL)
php7(FPM)
imagemagick7
roundcubemail-1.3.6
```
## Базовая настройка
### Для корректной работы, перед запуском контейнера, необходимо предварительно создать каталоги:
```
mkdir -p /home/roundcube/config
mkdir /home/roundcube/logs
```
### Так же необходимо выставить права доступа на каталоги:
```
chmod -R 655 /home/roundcube
chmod -R 666 /home/roundcube/logs
```
### Базовая настройка roundcubemail
Настройки roundcube будет считывать из каталога /home/roundcube/config.
Перед запуском контейнера необходимо в этот каталог поместить подготовленные файлы:
- default.inc.php
- config.inc.php
- mimetypes.php

Данные файлы можно получить, скачав исходные коды roundcubemail-1.3.6, с официального сайта roundcube.net.

### Плагины
-acl
-additional_message_headers
-archive
-attachment_reminder
-autologon
-chbox
-database_attachments
-debug_logger
-emoticons
-enigma
-example_addressbook
-filesystem_attachments
-filters
-help
-hide_blockquote
-http_authentication
-identicon
-identity_select
-jqueryui
-krb_authentication
-managesieve
-markasjunk
-new_user_dialog
-new_user_identity
-newmail_notifier
-redundant_attachments
-show_additional_headers
-squirrelmail_usercopy
-subscriptions_option
-userinfo
-vcard_attachments
-virtuser_file
-virtuser_query
-zipdownload

Большая часть плагинов уже настроена, остальные настройки делаются в файле /home/roundcube/config/config.inc.php.

Набор плагинов так же можно посмотреть после запуска контейнера, выполнив команды:
```
docker exec rcmail136 ls /home/roundcube/plugins
```

## Запуск docker-контейнера
### Параметры по умолчанию
```
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
ENV FPM_MAX_CHILDREN 	40
# Число дочерних процессов, создаваемых при запуске (pm dynamic)
ENV FPM_START_SERVERS 	1
# Минимальное число неактивных дочерних процессов (pm dynamic)
ENV FPM_MIN_SPARE_SERVERS 1
# Максимальное число неактивных дочерних процессов сервера (pm dynamic)
ENV FPM_MAX_SPARE_SERVERS 10
```
### Пример команды запуска контейнера
```
docker run -d --name rcmail136 \
    -p 8443:443 \
    -e PHP_MEMORY_LIMIT=64M \
    -e MAX_UPLOAD=50M \
    -e PHP_MAX_FILE_UPLOAD=20 \
    -e PHP_MAX_POST=51M \
    -e FPM_MAX_CHILDREN=20 \
    -e FPM_START_SERVERS=2 \
    -e FPM_MIN_SPARE_SERVERS=2 \
    -e FPM_MAX_SPARE_SERVERS=10 \
    -v /home/roundcube/config:/home/roundcube/config \
    -v /home/roundcube/logs:/home/roundcube/logs \
    --restart unless-stopped rcmail/rcmail:latest
```
## Дополнительные настройки roundcubemail и прочего (/home/roundcube/config/config.inc.php)
```
// managesieve
$config['managesieve_port'] = 4190;
$config['managesieve_host'] = '172.17.0.1';
//mimetypes
$config['mime_types'] = '/home/roundcube/mime.types';
```