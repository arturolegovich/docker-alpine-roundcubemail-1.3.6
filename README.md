# docker-alpine-roundcubemail-1.3.6
docker alpine roundcubemail 1.3.6 with php7-fpm

docker run command:
docker run -d --name rcmail136 -p 8080:80 -p 8443:443 -v /home/roundcube/config:/home/roundcube/config --restart unless-stopped rcmail/rcmail:latest