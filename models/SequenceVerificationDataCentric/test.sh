#!/bin/bash
CMD="AESequenceDC_transient_standalone -log-level Debug -postinit schedule/test.sch -util Inspector"
mkdir -p test_results/
DOCKER_RUN="docker compose -f ../../bin/docker-compose.yml run -v /${PWD}:/work run"
${DOCKER_RUN} bash -c "source /work/build/Release/generators/conanrun.sh && export PATH=/work/build/Release/bin:${PATH} && ${CMD}"
