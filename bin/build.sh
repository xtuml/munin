#!/bin/bash
set -e
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
CMD=build
if [[ $# > 0 && $1 = "test" ]]; then
	CMD=build-test
fi
docker compose -f ${SCRIPT_DIR}/docker-compose.yml run -v /${PWD}:/work ${CMD}
