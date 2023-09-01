#!/bin/bash
set -e
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
docker compose -f ${SCRIPT_DIR}/docker-compose.yml run -v /${PWD}:/work build
docker compose -f ${SCRIPT_DIR}/docker-compose.yml run -v /${PWD}:/work install-deploy
docker build -t ghcr.io/xtuml/protocol_verifier:latest .
