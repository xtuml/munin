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
puml_file="../tests/PumlForTesting/PumlRegression/SimpleSequenceJob.puml"

# generate job definitions
echo "Generating job definitions..."
$P2J --job -o config/job_definitions $puml_file
echo "Done."

# launch the protocol verifier
echo "Launching protocol verifier..."
docker compose down
docker compose up -d &>/dev/null
echo "Done."

echo "Generating runtime events."
$P2J --play -o reception-incoming $puml_file --play --injectAb4B SSJA SSJB
$P2J --play -o reception-incoming $puml_file --play --injectAb4B SSJA SSJC
$P2J --play -o reception-incoming $puml_file --play --injectAb4B SSJA SSJD
$P2J --play -o reception-incoming $puml_file --play --injectAb4B SSJA SSJE
$P2J --play -o reception-incoming $puml_file --play --injectAb4B SSJB SSJA
$P2J --play -o reception-incoming $puml_file --play --injectAb4B SSJB SSJC
$P2J --play -o reception-incoming $puml_file --play --injectAb4B SSJB SSJD
$P2J --play -o reception-incoming $puml_file --play --injectAb4B SSJB SSJE
$P2J --play -o reception-incoming $puml_file --play --injectAb4B SSJC SSJA
$P2J --play -o reception-incoming $puml_file --play --injectAb4B SSJC SSJB
$P2J --play -o reception-incoming $puml_file --play --injectAb4B SSJC SSJD
$P2J --play -o reception-incoming $puml_file --play --injectAb4B SSJC SSJE
$P2J --play -o reception-incoming $puml_file --play --injectAb4B SSJD SSJA
$P2J --play -o reception-incoming $puml_file --play --injectAb4B SSJD SSJB
$P2J --play -o reception-incoming $puml_file --play --injectAb4B SSJD SSJC
$P2J --play -o reception-incoming $puml_file --play --injectAb4B SSJD SSJE
$P2J --play -o reception-incoming $puml_file --play --injectAb4B SSJE SSJA
$P2J --play -o reception-incoming $puml_file --play --injectAb4B SSJE SSJB
$P2J --play -o reception-incoming $puml_file --play --injectAb4B SSJE SSJC
$P2J --play -o reception-incoming $puml_file --play --injectAb4B SSJE SSJD
echo "Done."

# wait a reasonable amount of time
delay=45
echo "Waiting ${delay} seconds for protocol verifier to complete..."
sleep $delay
echo "Done."

# make sure there is a success log for every job definition
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)
exit_code=0
echo "Checking results..."
echo "--------------------------------------------------"
# Check for job_failed and be sure no success or alarm.
for fn in config/job_definitions/*.json; do
	grep "svdc_job_failed" logs/protocol_verifier/pv.log &>/dev/null
	if [[ $? == 0 ]]; then
		grep "svdc_job_success" logs/protocol_verifier/pv.log &>/dev/null
		if [[ $? != 0 ]]; then
			grep "svdc_job_alarm" logs/protocol_verifier/pv.log &>/dev/null
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
