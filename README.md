# docker-alpine-roundcubemail-1.3.6
docker alpine roundcubemail 1.3.6 with php7-fpm

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

docker run command:
docker run -d --name rcmail136 -p 8080:80 -p 8443:443 -e MAX_UPLOAD=25M  -v /home/roundcube/config:/home/roundcube/config --restart unless-stopped rcmail/rcmail:latest

config.inc.php:
// managesieve
$config['managesieve_port'] = 4190;
$config['managesieve_host'] = 'localhost';
