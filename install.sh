#!/bin/bash
docker-compose build --pull
docker-compose up -d
sleep 120
docker exec --user www-data nextcloud php occ config:system:set overwriteprotocol --value="https"