#!/bin/sh
docker container stop rcmail136_php56
docker container rm rcmail136_php56
docker image rm rcmail/rcmail:devel_php56
#docker run -d \
#  --name rcmail136_php56 \
#  -p 8443:443 \
#  -v /home/roundcube/config:/home/roundcube/config \
#  -v /home/roundcube/logs:/home/roundcube/logs \
#  --restart unless-stopped rcmail/rcmail:devel_php56
