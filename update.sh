#!/bin/sh
docker container stop rcmail136
docker container rm rcmail136
docker image rm rcmail/rcmail:latest
docker run -d \
  --name rcmail136 \
  -p 8443:443 \
  -v /home/roundcube/config:/home/roundcube/config \
  -v /home/roundcube/logs:/home/roundcube/logs \
  --restart unless-stopped rcmail/rcmail:latest
