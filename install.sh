#!/bin/bash
set -euo pipefail
docker-compose build --pull
mkdir -p datadir/nextcloud/data
mkdir -p datadir/nextcloud/main
mkdir -p datadir/nextcloud/ssddata
docker-compose up -d
sleep 120
docker exec --user www-data nextcloud php occ config:system:set overwriteprotocol --value="https"