#!/bin/bash
set -e
bash -c "cd AEOrdering && ../../bin/build.sh $@"
bash -c "cd FileReception && ../../bin/build.sh $@"
bash -c "cd InvariantStore && ../../bin/build.sh $@"
bash -c "cd SequenceVerificationDataCentric && ../../bin/build.sh $@"
bash -c "cd VerificationGateway && ../../bin/build.sh $@"
bash -c "cd JobManagement && ../../bin/build.sh $@"
if [[ $# < 1 || $1 != "test" ]]; then
	bash -c "cd PV_PROC && ../../bin/clean.sh && ../../bin/build.sh"
fi
