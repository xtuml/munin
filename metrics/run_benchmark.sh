#!/bin/bash
set -e

BATCH_OF_EVENTS=10000
EVENTS_PER_SECOND=1000
TOTAL_EVENTS=100000
if [[ $# -ge 2 ]] ; then
  EVENTS_PER_SECOND=$1
  TOTAL_EVENTS=$2
fi
ITERATIONS=$(($TOTAL_EVENTS / $BATCH_OF_EVENTS))

# Allow over-riding the kafka topic (for Linux builds)
RECEPTION_TOPIC="default.AEReception_service0"
if [[ $# -ge 3 ]] ; then
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
# plus2json leaks memory when running continously.
# Loop it up to free memory after small batches of events.
for ((i = 0; i < $ITERATIONS; i++)); do
  echo ${puml_files} | xargs python ../bin/plus2json.pyz --play --msgbroker localhost:9092 --topic $RECEPTION_TOPIC --shuffle --rate $EVENTS_PER_SECOND --num-events $BATCH_OF_EVENTS
done
sleep 5
echo "Done."

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
