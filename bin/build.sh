#!/bin/bash
set -e
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
if [[ $# > 0 && $1 = "test" ]]; then
	export INCLUDE_TEST=True
fi
source ${SCRIPT_DIR}/.env
docker compose -f ${SCRIPT_DIR}/docker-compose.yml run --rm -e MASL_VERSION=${MASL_VERSION} -e MUNIN_VERSION=$(git describe --tags) -v /${PWD}:/work build
