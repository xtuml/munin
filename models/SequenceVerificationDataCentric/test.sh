#!/bin/bash
CMD="AESequenceDC_transient_standalone -log-level Debug -postinit schedule/test.sch -util Inspector"
DOCKER_RUN="docker compose -f ../../bin/docker-compose.yml run -v /${PWD}:/work run"
${DOCKER_RUN} bash -c "source /work/build/Release/generators/conanrun.sh && export PATH=/work/build/Release/bin:${PATH} && ${CMD}"
if [[ "$(jq -r -s '. | all(.result != "FAILED" and .result != "ERROR")' test_results/*.json)" != "true" ]]; then
	echo "$(tput setaf 1)There are test failures!$(tput sgr0)"
else
	echo "$(tput setaf 2)All tests passed.$(tput sgr0)"
fi
