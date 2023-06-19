#!/bin/bash

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

# generate test event data
echo "Generating event data..."
echo ${puml_files} | xargs python ../bin/plus2json.pyz --play -o reception-incoming --num-events 10000 --batch-size 50 --shuffle
echo "Done."

# launch the application
echo "Launching the application..."
cd ../metrics && docker compose up -d &> /dev/null
sleep 10
cd ../deploy && docker compose -f docker-compose.benchmark.yml up -d &> /dev/null
echo "Done."

# wait until the logs stop changing
echo "Waiting for the test to finish..."
mod_time="0"
new_mod_time="1"
while [[ "${mod_time}" != "${new_mod_time}" ]]; do
  sleep 5;
  mod_time=${new_mod_time}
  new_mod_time="$(stat -c %Y logs/verifier/Verifier.log)"
  # new_mod_time="$(stat -f %m logs/verifier/Verifier.log)"  # Uncomment for use on macOS
done
sleep 10;
echo "Done."

# run the benchmark script
echo "Processing report..."
python ../metrics/benchmark.py
echo "Done."

# tear down docker
echo "Tearing down the application..."
docker compose -f docker-compose.benchmark.yml down
cd ../metrics && docker compose down
echo "Done."

exit_code=0
exit ${exit_code}
