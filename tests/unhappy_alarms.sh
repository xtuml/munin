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
puml_file_1="../tests/PumlForTesting/PumlRegression/ACritical1.puml"
puml_file_2="../tests/PumlForTesting/PumlRegression/ACritical2.puml"
puml_file_3="../tests/PumlForTesting/PumlRegression/ACritical3.puml"

# generate job definitions
echo "Generating job definitions..."
$P2J --job -o config/job_definitions $puml_file_1
$P2J --job -o config/job_definitions $puml_file_2
$P2J --job -o config/job_definitions $puml_file_3
echo "Done."

# launch the protocol verifier
echo "Launching protocol verifier..."
docker compose down
docker compose up -d &>/dev/null
echo "Done."

echo "Generating runtime events."
set -x
$P2J --play -o reception-incoming $puml_file_1 --play --sibling CSJC
$P2J --play -o reception-incoming $puml_file_1 --play --replace CSJA
$P2J --play -o reception-incoming $puml_file_1 --play --replace CSJC
$P2J --play -o reception-incoming $puml_file_1 --play --replace CSJD
$P2J --play -o reception-incoming $puml_file_1 --play --orphan CSJI
$P2J --play -o reception-incoming $puml_file_1 --play --sibling CSJA
$P2J --play -o reception-incoming $puml_file_1 --play --insert CSJE
$P2J --play -o reception-incoming $puml_file_2 --play --sibling CSJC
$P2J --play -o reception-incoming $puml_file_2 --play --replace CSJA
$P2J --play -o reception-incoming $puml_file_2 --play --replace CSJC
$P2J --play -o reception-incoming $puml_file_2 --play --orphan CSJI
$P2J --play -o reception-incoming $puml_file_2 --play --sibling CSJA
$P2J --play -o reception-incoming $puml_file_3 --play --replace CSJ3A
$P2J --play -o reception-incoming $puml_file_3 --play --sibling CSJ3C
$P2J --play -o reception-incoming $puml_file_3 --play --replace CSJ3C
$P2J --play -o reception-incoming $puml_file_3 --play --replace CSJ3F
$P2J --play -o reception-incoming $puml_file_3 --play --sibling CSJ3G
$P2J --play -o reception-incoming $puml_file_3 --play --orphan CSJ3B
set +x
echo "Done."

# wait a reasonable amount of time
delay=15
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
	grep "svdc_job_alarm" logs/verifier/Verifier.log &>/dev/null
	if [[ $? == 0 ]]; then
		grep "svdc_job_success" logs/verifier/Verifier.log &>/dev/null
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
