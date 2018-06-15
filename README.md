# docker-alpine-roundcubemail-1.3.6
docker alpine roundcubemail 1.3.6 with php7-fpm

docker run command:
docker run -d --name roundcubemail_1_3_6 -p 8080:80 -v /home/roundcube/config:/home/roundcube/config --restart unless-stopped rcmail:latest