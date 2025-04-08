#!/bin/bash
set -e
export MUNIN_VERSION=$(git describe --tags)
cd aeo_svdc_proc && ../stage-project.sh && docker build -t ghcr.io/xtuml/aeo_svdc_proc:${MUNIN_VERSION} -t ghcr.io/xtuml/aeo_svdc_proc:latest .
cd ../istore_proc && ../stage-project.sh && docker build -t ghcr.io/xtuml/istore_proc:${MUNIN_VERSION} -t ghcr.io/xtuml/istore_proc:latest .
cd ../jm_proc && ../stage-project.sh && docker build -t ghcr.io/xtuml/jm_proc:${MUNIN_VERSION} -t ghcr.io/xtuml/jm_proc:latest .
cd ../pv_proc && ../stage-project.sh && docker build -t ghcr.io/xtuml/protocol_verifier:${MUNIN_VERSION} -t ghcr.io/xtuml/protocol_verifier:latest .
