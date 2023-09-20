#!/bin/bash
set -e

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
echo "Done."

# launch the application
echo "Launching the application..."
export CONFIG_FILE=benchmarking-config.json
docker compose -f docker-compose.kafka.yml up -d --wait &>/dev/null
echo "Done."

# generate test event data
echo "Generating event data..."
# little delay to assure everything is initialized
sleep 2
echo ${puml_files} | xargs python ../bin/plus2json.pyz --play --msgbroker localhost:9092 --topic default.AEReception_service0 --shuffle --num-events 100000
echo "Done."

# run the benchmark script
echo "Waiting for application to finish..."
python ../metrics/benchmark.py --msgbroker localhost:9092 --topic default.BenchmarkingProbe_service0
echo "Done."

# tear down docker
echo "Tearing down the application..."
docker compose -f docker-compose.kafka.yml down
echo "Done."

exit_code=0
exit ${exit_code}
