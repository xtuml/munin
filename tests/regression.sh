#!/bin/bash

# prepare the deploy folder
echo "Preparing deploy location..."
cd ../deploy
git clean -dxf .
echo "Done."

# get list of puml files
puml_files=$(ls -1 ../tests/PumlForTesting/PumlRegression/*.puml | sort)

# generate job definitions
for fn in ${puml_files}; do
  echo "Generating job definition for '${fn}'..."
  python ../bin/plus2json.pyz ${fn} --job --outdir config/job_definitions
  echo "Done."
done

# launch the protocol verifier
echo "Launching protocol verifier..."
docker compose up -d &> /dev/null
echo "Done."

# play all jobs
for fn in ${puml_files}; do
  echo "Generating runtime event data for '${fn}'..."
  python ../bin/plus2json.pyz ${fn} --play --outdir reception-incoming
  echo "Done."
  sleep 1
done

# wait a reasonable amount of time
echo "Waiting for protocol verifier to complete..."
sleep 5
echo "Done."

# make sure there is a success log for every job definition
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)
exit_code=0
echo "Checking results..."
echo "--------------------------------------------------"
for fn in config/job_definitions/*.json; do
  job_name=$(jq -r '.JobDefinitionName' "${fn}")
  grep "svdc_job_success : JobId = [a-f0-9-]* : JobName = ${job_name}" logs/verifier/Verifier.log &> /dev/null
  if [[ $? == 0 ]]; then
    printf "%-40s %s\n" "${job_name}" "[${GREEN}SUCCESS${NORMAL}]"
  else
    printf "%-40s %s\n" "${job_name}" "[${RED}FAILURE${NORMAL}]"
    exit_code=1
  fi
done
echo "--------------------------------------------------"
echo "Done."

# tear down the protocol verifier
echo "Tearing down protocol verifier..."
docker compose down
echo "Done."

# clean up repository
#echo "Cleaning deploy location..."
#git clean -dxf .
#echo "Done."

exit ${exit_code}