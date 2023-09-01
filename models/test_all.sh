#!/bin/bash
set -e
bash -c "cd AEOrdering && ./test.sh $@"
bash -c "cd AEReception && ./test.sh $@"
bash -c "cd FileReception && ./test.sh $@"
bash -c "cd InvariantStore && ./test.sh $@"
bash -c "cd SequenceVerificationDataCentric && ./test.sh $@"
