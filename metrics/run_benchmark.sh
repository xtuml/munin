#!/bin/bash
set -e

# Usage:
# run_benchmark.sh [rate (events/second)] [total number of events] [reception topic]
# Executution defaults to:  run_benchmark.sh 1000 100000 Protocol_Verifier_Reception

# Define batches of events for p2j to play.
BATCH_OF_EVENTS=100000
EVENTS_PER_SECOND=1000
TOTAL_EVENTS=100000
if [[ $# -ge 2 ]] ; then
  EVENTS_PER_SECOND=$1
  TOTAL_EVENTS=$2
  if [[ $BATCH_OF_EVENTS -gt $TOTAL_EVENTS ]] ; then
    BATCH_OF_EVENTS=$TOTAL_EVENTS
  fi
fi
ITERATIONS=$(($TOTAL_EVENTS / $BATCH_OF_EVENTS))

# Allow over-riding the kafka topic for reception.
RECEPTION_TOPIC="Protocol_Verifier_Reception"
if [[ $# -ge 3 ]] ; then
  RECEPTION_TOPIC=$3
fi

# prepare the deploy folder
echo "Preparing deploy location..."
cd ../deploy
git clean -dxf .
echo "Done."

# get list of puml files (stripping DOS CR)
puml_files=$(cat ../metrics/benchmark_job_definitions.txt | sed "s/\r$//")

# generate job definitions
echo "Generating job definitions..."
echo ${puml_files} | xargs python ../bin/plus2json.pyz --job -o config/job_definitions
echo "../tests/PumlForTesting/PumlRegression/AAExtraJobInvariantSourceJob.puml" | xargs python ../bin/plus2json.pyz --job -o config/job_definitions
echo "Done."

# launch the application
echo "Launching the application..."
export CONFIG_FILE=benchmarking-config.json
docker compose -f docker-compose.kafka.yml up -d --wait
echo "Done."

# generate source job
echo "Generating invariant source runtime event stream..."
# little delay to assure everything is initialized
sleep 5
echo "../tests/PumlForTesting/PumlRegression/AAExtraJobInvariantSourceJob.puml" | xargs python ../bin/plus2json.pyz --play --msgbroker localhost:9092 --topic $RECEPTION_TOPIC
echo "Done."

# generate test event data
echo "Generating audit event stream..."
sleep 1
echo start `date` $TOTAL_EVENTS "at" $EVENTS_PER_SECOND "on" `hostname` >> runtime.txt
start_seconds=`date +%s`
# plus2json leaks memory when running continously.
# Loop it up to free memory after small batches of events.
echo "0 of " $TOTAL_EVENTS
LOOP_COUNT=0
for ((i = 0; i < $ITERATIONS; i++)); do
  echo ${puml_files} | xargs python ../bin/plus2json.pyz --play --msgbroker localhost:9092 --topic $RECEPTION_TOPIC --shuffle --rate $EVENTS_PER_SECOND --num-events $BATCH_OF_EVENTS
  LOOP_COUNT=$(($LOOP_COUNT + 1))
  echo $(($LOOP_COUNT * $BATCH_OF_EVENTS)) " of " $TOTAL_EVENTS
done
stop_seconds=`date +%s`
echo "stop " `date` >> runtime.txt
runtime=$(($stop_seconds - $start_seconds))
events_per_second=$(($TOTAL_EVENTS / $runtime))
echo $runtime "seconds at rate:" $events_per_second >> runtime.txt
sleep 20
echo "Done."

# run the benchmark script
echo "Running benchmark calculations..."
python ../metrics/benchmark.py --msgbroker localhost:9092 --topic BenchmarkingProbe_service0
echo "Done."

# tear down docker
echo "Tearing down the application... (ctrl-c to leave it running)"
sleep 10
docker compose -f docker-compose.kafka.yml down
echo "Done."

exit_code=0
exit ${exit_code}
