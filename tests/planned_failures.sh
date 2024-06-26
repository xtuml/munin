#!/bin/bash

# print plus2json version
P2J="python ../bin/plus2json.pyz"
$P2J -v

# prepare the deploy folder
echo "Preparing deploy location..."
cd ../deploy
git clean -dxf .
echo "Done."

# get list of puml files
puml_files=$(ls -1 ../tests/PumlForTesting/PumlRegression/*.puml | sort)

# generate job definitions
echo "Generating job definitions..."
echo ${puml_files} | xargs $P2J --job -o config/job_definitions
echo "Done."

# launch the protocol verifier
echo "Launching protocol verifier..."
docker compose down
docker compose up -d &>/dev/null
echo "Done."

echo "Generating runtime events."
$P2J --play -o reception-incoming ../tests/PumlForTesting/PumlRegression/SimpleSequenceJob.puml --omit SSJA
$P2J --play -o reception-incoming ../tests/PumlForTesting/PumlRegression/SimpleSequenceJob.puml --omit SSJB
$P2J --play -o reception-incoming ../tests/PumlForTesting/PumlRegression/SimpleSequenceJob.puml --omit SSJC
$P2J --play -o reception-incoming ../tests/PumlForTesting/PumlRegression/SimpleSequenceJob.puml --omit SSJD
$P2J --play -o reception-incoming ../tests/PumlForTesting/PumlRegression/SimpleSequenceJob.puml --omit SSJE 
$P2J --play -o reception-incoming ../tests/PumlForTesting/PumlRegression/SimpleSequenceJob.puml --injectAb4B SSJA SSJC
$P2J --play -o reception-incoming ../tests/PumlForTesting/PumlRegression/SimpleSequenceJob.puml --injectAb4B SSJB SSJD
$P2J --play -o reception-incoming ../tests/PumlForTesting/PumlRegression/SimpleSequenceJob.puml --injectAb4B SSJC SSJE
echo "Done."

# wait a reasonable amount of time
delay=3
echo "Waiting ${delay} seconds for protocol verifier to complete..."
sleep $delay
echo "Done."

# make sure there is a failure log for every job definition
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)
exit_code=0
echo "Checking results..."
echo "--------------------------------------------------"
# Check for job_failed and be sure no success or alarm.
for fn in config/job_definitions/*.json; do
	job_name=$(jq -r '.JobDefinitionName' "${fn}")
	grep 'svdc_job_failed :\|: JobId = [a-f0-9-]* with Job Name = ${job_name}' logs/protocol_verifier/pv.log &>/dev/null
	if [[ $? == 0 ]]; then
		grep "svdc_job_success" logs/protocol_verifier/pv.log &>/dev/null
		if [[ $? != 0 ]]; then
			printf "%-40s %s\n" "${job_name}" "[${GREEN}SUCCESS${NORMAL}]"
		else
			printf "%-40s %s\n" "${job_name}" "[${RED}FAILURE${NORMAL}]"
			exit_code=1
		fi
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
