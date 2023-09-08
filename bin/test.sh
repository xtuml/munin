#!/bin/bash
set -e
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
docker compose -f ${SCRIPT_DIR}/docker-compose.yml --env-file ./test.env run -v /${PWD}:/work test
if [[ "$(jq -r -s '. | all(.result != "FAILED" and .result != "ERROR")' test_results/*.json)" != "true" ]]; then
	echo "$(tput setaf 1)There are test failures!$(tput sgr0)"
else
	echo "$(tput setaf 2)All tests passed.$(tput sgr0)"
fi
