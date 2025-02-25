#!/bin/bash
set -e

# Usage:
# run_benchmark.sh [rate (events/second)] [total number of events] [prepopulated events] [reception topic]
# Executution defaults to:  run_benchmark.sh 1000 100000 0 Protocol_Verifier_Reception

P2J="python ../bin/plus2json.pyz"
# Define batches of events for p2j to play.
BATCH_OF_EVENTS=1000000
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

# Define prepopulation quantity.
PREPOPULATION_QUANTITY=0
if [[ $# -ge 3 ]] ; then
  PREPOPULATION_QUANTITY=$3
fi

# Allow over-riding the kafka topic for reception.
RECEPTION_TOPIC="Protocol_Verifier_Reception"
if [[ $# -ge 4 ]] ; then
  RECEPTION_TOPIC=$4
fi

# prepare the deploy folder
echo "Preparing deploy location..."
cd ../deploy
git clean -dxf .
echo "Done."

# get list of puml files (stripping DOS CR)
puml_files=$(cat ../metrics/benchmark_job_definitions.txt | sed "s/\r$//")
puml_file_for_injection="../tests/PumlForTesting/PumlRegression/ACritical2.puml"
puml_file_for_alarm="../tests/PumlForTesting/PumlRegression/ACritical1.puml"
puml_file_for_prepopulation="../tests/PumlForTesting/PumlRegression/SimpleSequenceJob.puml"

# generate job definitions
echo "Generating job definitions..."
echo ${puml_files} | xargs $P2J --job -o config/job_definitions
echo "../tests/PumlForTesting/PumlRegression/AAExtraJobInvariantSourceJob.puml" | xargs $P2J --job -o config/job_definitions
echo "Done."

if [[ $PREPOPULATION_QUANTITY -gt 0 ]] ; then

  # launch the broker
  echo "Launching the message broker..."
  docker compose -f docker-compose.onlykafka.yml up -d --wait
  echo "Done."

  echo "Prepopulating broker with" $PREPOPULATION_QUANTITY "events..."
  #Kafkaecho ${puml_file_for_prepopulation} | xargs $P2J --play --msgbroker localhost:9092 --topic $RECEPTION_TOPIC --shuffle --rate $EVENTS_PER_SECOND --num-events $PREPOPULATION_QUANTITY
  echo ${puml_file_for_prepopulation} | xargs $P2J --play --amqpbroker localhost:61613 --keyfile /tmp/client.key --certfile /tmp/client.pem --certbroker /tmp/broker.pem --topic $RECEPTION_TOPIC --shuffle --rate $EVENTS_PER_SECOND --num-events $PREPOPULATION_QUANTITY
  #NOSSLecho ${puml_file_for_prepopulation} | xargs $P2J --play --amqpbroker localhost:61613 --topic $RECEPTION_TOPIC --shuffle --rate $EVENTS_PER_SECOND --num-events $PREPOPULATION_QUANTITY
  echo "Done."

  # launch the application
  echo "Launching the application..."
  export CONFIG_FILE=benchmarking-config.json
  docker compose -f docker-compose.onlypv.yml up -d --wait
  echo "Done."

else

  # launch the broker and application
  echo "Launching the application..."
  export CONFIG_FILE=benchmarking-config.json
  docker compose -f docker-compose.kafka.yml up -d --wait
  echo "Done."

fi

# launch the AMQP to Kafka bridge
echo "Launching amqp2kafka.py."
python ../doc/notes/247_deployment_readiness/activemq/amqp2kafka.py &
AMQP2KAFKA_PID=$!

# generate source job
echo "Generating invariant source runtime event stream..."
# little delay to assure everything is initialized
sleep 1
#Kafkaecho "../tests/PumlForTesting/PumlRegression/AAExtraJobInvariantSourceJob.puml" | xargs $P2J --play --msgbroker localhost:9092 --topic $RECEPTION_TOPIC
echo "../tests/PumlForTesting/PumlRegression/AAExtraJobInvariantSourceJob.puml" | xargs $P2J --play --amqpbroker localhost:61613 --keyfile /tmp/client.key --certfile /tmp/client.pem --certbroker /tmp/broker.pem --topic $RECEPTION_TOPIC
#NOSSLecho "../tests/PumlForTesting/PumlRegression/AAExtraJobInvariantSourceJob.puml" | xargs $P2J --play --amqpbroker localhost:61613 --topic $RECEPTION_TOPIC
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
  #Kafkaecho ${puml_files} | xargs $P2J --play --msgbroker localhost:9092 --topic $RECEPTION_TOPIC --shuffle --event-array --batch-size 500 --rate $EVENTS_PER_SECOND --num-events $BATCH_OF_EVENTS
  #BatchByJobecho ${puml_files} | xargs $P2J --play --amqpbroker localhost:61613 --keyfile /tmp/client.key --certfile /tmp/client.pem --certbroker /tmp/broker.pem --topic $RECEPTION_TOPIC --shuffle --event-array --batch-by-job --rate $EVENTS_PER_SECOND --num-events $BATCH_OF_EVENTS
  echo ${puml_files} | xargs $P2J --play --amqpbroker localhost:61613 --keyfile /tmp/client.key --certfile /tmp/client.pem --certbroker /tmp/broker.pem --topic $RECEPTION_TOPIC --shuffle --event-array --batch-size 500 --rate $EVENTS_PER_SECOND --num-events $BATCH_OF_EVENTS
  #NOSSLecho ${puml_files} | xargs $P2J --play --amqpbroker localhost:61613 --topic $RECEPTION_TOPIC --shuffle --event-array --batch-size 500 --rate $EVENTS_PER_SECOND --num-events $BATCH_OF_EVENTS
  if [[ $# -lt 3 ]] ; then
    # Inject an error to fail one job.
    echo "Inject error to fail a job."
    #Kafka$P2J ${puml_file_for_injection} --play --msgbroker localhost:9092 --topic $RECEPTION_TOPIC --omit CSJI
    $P2J ${puml_file_for_injection} --play --amqpbroker localhost:61613 --keyfile /tmp/client.key --certfile /tmp/client.pem --certbroker /tmp/broker.pem --topic $RECEPTION_TOPIC --omit CSJI
    #NOSSL$P2J ${puml_file_for_injection} --play --amqpbroker localhost:61613 --topic $RECEPTION_TOPIC --omit CSJI
    echo "Inject error to alarm a job."
    #Kafka$P2J ${puml_file_for_alarm} --play --msgbroker localhost:9092 --topic $RECEPTION_TOPIC --sibling CSJC
    $P2J ${puml_file_for_alarm} --play --amqpbroker localhost:61613 --keyfile /tmp/client.key --certfile /tmp/client.pem --certbroker /tmp/broker.pem --topic $RECEPTION_TOPIC --sibling CSJC
    #NOSSL$P2J ${puml_file_for_alarm} --play --amqpbroker localhost:61613 --topic $RECEPTION_TOPIC --sibling CSJC
  fi
  LOOP_COUNT=$(($LOOP_COUNT + 1))
  echo $(($LOOP_COUNT * $BATCH_OF_EVENTS)) " of " $TOTAL_EVENTS
done
stop_seconds=`date +%s`
echo "stop " `date` >> runtime.txt
runtime=$(($stop_seconds - $start_seconds))
events_per_second=$(($TOTAL_EVENTS / $runtime))
echo $runtime "seconds at rate:" $events_per_second >> runtime.txt
echo "Done."
if [[ $# -ge 3 ]] ; then
  echo "Press ENTER to continue..."
  read a
else
  sleep 60
fi

# Kill off the AMQP to Kafka bridge.
kill $AMQP2KAFKA_PID

# run the benchmark script
echo "Running benchmark calculations..."
python ../metrics/benchmark.py --msgbroker localhost:9092 --topic BenchmarkingProbe_service0
echo "Done."

# tear down docker
echo "Tearing down the application... (ctrl-c to leave it running)"
sleep 2
docker compose -f docker-compose.kafka.yml down
echo "Done."

exit_code=0
exit ${exit_code}
