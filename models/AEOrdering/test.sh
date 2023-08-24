#!/bin/bash
JOB_DEFINITION_SCHEMA_PATH=schema/job_definition_schema.json
ORDERING_CONFIG_SCHEMA_PATH=schema/ordering_config_schema.json
CMD="AEOrdering_transient_standalone -log-level Debug -configPath config/ -configFile aeordering_spec_test.json -postinit schedule/test.sch -startJobGroup 00 -endJobGroup FF -util Inspector"
DOCKER_RUN="docker compose -f ../../bin/docker-compose.yml run -e JOB_DEFINITION_SCHEMA_PATH=${JOB_DEFINITION_SCHEMA_PATH} -e ORDERING_CONFIG_SCHEMA_PATH=${ORDERING_CONFIG_SCHEMA_PATH} -v /${PWD}:/work run"
${DOCKER_RUN} bash -c "source /work/build/Release/generators/conanrun.sh && export PATH=/work/build/Release/bin:${PATH} && ${CMD}"
if [[ "$(jq -r -s '. | all(.result != "FAILED" and .result != "ERROR")' test_results/*.json)" != "true" ]]; then
	echo "$(tput setaf 1)There are test failures!$(tput sgr0)"
else
	echo "$(tput setaf 2)All tests passed.$(tput sgr0)"
fi
