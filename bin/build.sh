#!/bin/bash
set -e
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
if [[ $# > 0 && $1 = "test" ]]; then
	export INCLUDE_TEST=True
fi
source ${SCRIPT_DIR}/.env
docker compose -f ${SCRIPT_DIR}/docker-compose.yml run -e MASL_VERSION=${MASL_VERSION} -v /${PWD}:/work build
