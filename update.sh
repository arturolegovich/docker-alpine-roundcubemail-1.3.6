#!/bin/sh
docker container stop rcmail136_php56
docker container rm rcmail136_php56
docker image rm rcmail/rcmail:devel_php56
docker run -d --name rcmail136_php65 \
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
    --restart unless-stopped rcmail/rcmail:devel_php56