#!/bin/bash
set -e
bash -c "cd AEOrdering && ../../bin/clean.sh $@"
bash -c "cd AEReception && ../../bin/clean.sh $@"
bash -c "cd FileReception && ../../bin/clean.sh $@"
bash -c "cd InvariantStore && ../../bin/clean.sh $@"
bash -c "cd SequenceVerificationDataCentric && ../../bin/clean.sh $@"
bash -c "cd PV_PROC && ../../bin/clean.sh $@"
