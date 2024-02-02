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
docker compose up -d
echo "Done."

t0=`date +%s`
# play all jobs
for fn in ${puml_files}; do
	$P2J --play -o reception-incoming ${fn}
	sleep 0.1
done

# Delay only enough time to allow the unhappy jobs to finish (HangingJobTimer).
t1=`date +%s`
tdelta=$(($t1 - $t0))
delay=$((90 - $tdelta))
if [[ $delay -le 0 ]] ; then
  delay=1
fi
echo "Waiting ${delay} seconds for protocol verifier to complete..."
sleep $delay

# tear down the protocol verifier
echo "Tearing down protocol verifier..."
docker compose down
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
	grep "svdc_job_success : JobId = [a-f0-9-]* : JobName = ${job_name}" logs/verifier/Verifier.log &>/dev/null
	if [[ $? == 0 ]]; then
		printf "%-40s %s\n" "${job_name}" "[${GREEN}SUCCESS${NORMAL}]"
	else
		printf "%-40s %s\n" "${job_name}" "[${RED}FAILURE${NORMAL}]"
		exit_code=1
	fi
done
echo "--------------------------------------------------"
echo "Done."

# clean up repository
#echo "Cleaning deploy location..."
#git clean -dxf .
#echo "Done."

exit ${exit_code}
