#!/bin/sh

#exec tini grocy

docker run -d \
    --name=grocy-test \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=Europe/London \
    -p 9283:80 \
    -v /path/to/data:/config \
    --restart unless-stopped \
    lscr.io/linuxserver/grocy:latest
