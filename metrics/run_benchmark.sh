#!/bin/bash
set -e

EVENTS_PER_SECOND=1000
TOTAL_EVENTS=100000
if [[ $# -eq 2 ]] ; then
  EVENTS_PER_SECOND=$1
  TOTAL_EVENTS=$2
fi

# Allow over-riding the kafka topic (for Linux builds)
RECEPTION_TOPIC="default.AEReception_service0"
if [[ $# -eq 3 ]] ; then
  RECEPTION_TOPIC=$3
fi

# prepare the deploy folder
echo "Preparing deploy location..."
cd ../deploy
git clean -dxf .
echo "Done."

# get list of puml files
puml_files=$(cat ../metrics/benchmark_job_definitions.txt)

# generate job definitions
echo "Generating job definitions..."
echo ${puml_files} | xargs python ../bin/plus2json.pyz --job -o config/job_definitions
echo "../tests/PumlForTesting/PumlRegression/AAExtraJobInvariantSourceJob.puml" | xargs python ../bin/plus2json.pyz --job -o config/job_definitions
echo "Done."

# launch the application
echo "Launching the application..."
export CONFIG_FILE=benchmarking-config.json
docker compose -f docker-compose.kafka.yml up -d --wait &>/dev/null
echo "Done."

# generate source job
echo "Generating source..."
# little delay to assure everything is initialized
sleep 2
echo "../tests/PumlForTesting/PumlRegression/AAExtraJobInvariantSourceJob.puml" | xargs python ../bin/plus2json.pyz --play --msgbroker localhost:9092 --topic $RECEPTION_TOPIC
echo "Done."

# generate test event data
echo "Generating event data..."
# little delay to assure everything is initialized
sleep 2
echo ${puml_files} | xargs python ../bin/plus2json.pyz --play --msgbroker localhost:9092 --topic $RECEPTION_TOPIC --shuffle --rate $EVENTS_PER_SECOND --num-events $TOTAL_EVENTS
echo "Done."

echo "When PV is done, hit ENTER to continue."
read my_var

# run the benchmark script
echo "Running benchmark calculations..."
python ../metrics/benchmark.py --msgbroker localhost:9092 --topic default.BenchmarkingProbe_service0
echo "Done."

# tear down docker
echo "Tearing down the application..."
docker compose -f docker-compose.kafka.yml down
echo "Done."

exit_code=0
exit ${exit_code}
