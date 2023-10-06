#!/bin/bash
set -e
bash -c "cd AEOrdering && ../../bin/test.sh $@"
bash -c "cd AEReception && ../../bin/test.sh $@"
bash -c "cd FileReception && ../../bin/test.sh $@"
bash -c "cd InvariantStore && ../../bin/test.sh $@"
bash -c "cd SequenceVerificationDataCentric && ../../bin/test.sh $@"
bash -c "cd VerificationGateway && ../../bin/test.sh $@"
