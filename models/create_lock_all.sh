#!/bin/bash
set -e
bash -c "cd AEOrdering && ../../bin/create-lock.sh"
bash -c "cd FileReception && ../../bin/create-lock.sh"
bash -c "cd InvariantStore && ../../bin/create-lock.sh"
bash -c "cd SequenceVerificationDataCentric && ../../bin/create-lock.sh"
bash -c "cd VerificationGateway && ../../bin/create-lock.sh"
bash -c "cd JobManagement && ../../bin/create-lock.sh"
bash -c "cd PV_PROC && ../../bin/create-lock.sh"
