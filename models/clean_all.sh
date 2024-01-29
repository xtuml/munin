#!/bin/bash
set -e
bash -c "cd AsyncLogger && ../../bin/clean.sh $@"
bash -c "cd BenchmarkingProbe && ../../bin/clean.sh $@"
bash -c "cd AEOrdering && ../../bin/clean.sh $@"
bash -c "cd FileReception && ../../bin/clean.sh $@"
bash -c "cd InvariantStore && ../../bin/clean.sh $@"
bash -c "cd SequenceVerificationDataCentric && ../../bin/clean.sh $@"
bash -c "cd VerificationGateway && ../../bin/clean.sh $@"
bash -c "cd JobManagement && ../../bin/clean.sh $@"
bash -c "cd PV_PROC && ../../bin/clean.sh $@"
