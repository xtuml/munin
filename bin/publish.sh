#!/bin/bash
set -e
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
source ${SCRIPT_DIR}/.env
docker compose -f ${SCRIPT_DIR}/docker-compose.yml run --rm -e MASL_VERSION=${MASL_VERSION} -e MUNIN_VERSION=$(git describe --tags) -e ARTIFACTORY_USERNAME=${ARTIFACTORY_USERNAME} -e ARTIFACTORY_TOKEN=${ARTIFACTORY_TOKEN} -v /${PWD}:/work publish
