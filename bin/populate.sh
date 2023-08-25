#!/bin/bash
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
docker rm -f $(docker ps -aq --filter volume=munin_ConanCache)
docker volume rm munin_ConanCache
docker rm -f $(docker ps -aq --filter volume=munin_ConanServer)
docker volume rm munin_ConanServer
docker compose -f ${SCRIPT_DIR}/docker-compose.yml pull populate
docker compose -f ${SCRIPT_DIR}/docker-compose.yml run populate
