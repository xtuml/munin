#!/bin/bash
CMD="IStore_transient_standalone -postinit schedule/test.sch -util Inspector"
DOCKER_RUN="docker compose -f ../../bin/docker-compose.yml run -v /${PWD}:/work run"
${DOCKER_RUN} bash -c "source /work/build/Release/generators/conanrun.sh && export PATH=/work/build/Release/bin:${PATH} && ${CMD}"
