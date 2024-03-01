#!/bin/bash
set -e
bash -c "cd AsyncLogger && ../../bin/publish.sh"
bash -c "cd BenchmarkingProbe && ../../bin/publish.sh"
bash -c "cd AEOrdering && ../../bin/publish.sh"
bash -c "cd FileReception && ../../bin/publish.sh"
bash -c "cd InvariantStore && ../../bin/publish.sh"
bash -c "cd SequenceVerificationDataCentric && ../../bin/publish.sh"
bash -c "cd VerificationGateway && ../../bin/publish.sh"
bash -c "cd JobManagement && ../../bin/publish.sh"
bash -c "cd PV_PROC && ../../bin/publish.sh"
