#!/bin/bash
set -e
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
rm -rf test_results
TMP_FILE=$(mktemp) && cat ${SCRIPT_DIR}/.env ./test.env >${TMP_FILE}
docker compose -f ${SCRIPT_DIR}/docker-compose.yml --env-file ${TMP_FILE} run --rm -v /${PWD}:/work -p 20000:20000 -p 30000:30000 -p 40000:40000 test
if [[ "$(jq -r -s '. | all(.result != "FAILED" and .result != "ERROR")' test_results/*.json)" != "true" ]]; then
  echo "$(tput setaf 1)There are test failures!$(tput sgr0)"
else
  echo "$(tput setaf 2)All tests passed.$(tput sgr0)"
fi
