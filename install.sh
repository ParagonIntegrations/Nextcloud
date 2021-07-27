#!/bin/bash
docker-compose pull

docker exec --user www-data nextcloud php occ config:system:set overwriteprotocol --value="https"