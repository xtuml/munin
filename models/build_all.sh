#!/bin/bash
set -e
bash -c "cd AEOrdering && ../../bin/build.sh $@"
bash -c "cd AEReception && ../../bin/build.sh $@"
bash -c "cd AESimulator && ../../bin/build.sh $@"
bash -c "cd InvariantStore && ../../bin/build.sh $@"
bash -c "cd SequenceVerificationDataCentric && ../../bin/build.sh $@"
bash -c "cd AEO_SVDC && ../../bin/deploy.sh $@"
