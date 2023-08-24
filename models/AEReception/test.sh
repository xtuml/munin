#!/bin/bash
AUDIT_EVENT_SCHEMA_PATH=schema/audit_event_schema.json
RECEPTION_CONFIG_SCHEMA_PATH=schema/reception_config_schema.json
CMD="AEReception_transient_standalone -log-level Debug -configPath config/ -postinit schedule/test.sch -util Inspector"
DOCKER_RUN="docker compose -f ../../bin/docker-compose.yml run -e AUDIT_EVENT_SCHEMA_PATH=${AUDIT_EVENT_SCHEMA_PATH} -e RECEPTION_CONFIG_SCHEMA_PATH=${RECEPTION_CONFIG_SCHEMA_PATH} -v /${PWD}:/work run"
${DOCKER_RUN} bash -c "source /work/build/Release/generators/conanrun.sh && export PATH=/work/build/Release/bin:${PATH} && ${CMD}"
if [[ "$(jq -r -s '. | all(.result != "FAILED" and .result != "ERROR")' test_results/*.json)" != "true" ]]; then
	echo "$(tput setaf 1)There are test failures!$(tput sgr0)"
else
	echo "$(tput setaf 2)All tests passed.$(tput sgr0)"
fi
