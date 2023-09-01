#!/bin/bash
FILE_RECEPTION_CONFIG_SCHEMA_PATH=schema/file_reception_config_schema.json
CMD="FReception_transient_standalone -log-level Debug -configPath config/ -postinit schedule/test.sch -util Inspector"
DOCKER_RUN="docker compose -f ../../bin/docker-compose.yml run --service-ports -e FILE_RECEPTION_CONFIG_SCHEMA_PATH=${FILE_RECEPTION_CONFIG_SCHEMA_PATH} -v /${PWD}:/work run"
${DOCKER_RUN} bash -c "source /work/build/Release/generators/conanrun.sh && export PATH=/work/build/Release/bin:${PATH} && ${CMD}"
if [[ "$(jq -r -s '. | all(.result != "FAILED" and .result != "ERROR")' test_results/*.json)" != "true" ]]; then
	echo "$(tput setaf 1)There are test failures!$(tput sgr0)"
else
	echo "$(tput setaf 2)All tests passed.$(tput sgr0)"
fi
