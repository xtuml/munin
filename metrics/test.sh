#!/bin/bash

cd ../deploy
echo "starting"
puml_files=$(cat ../metrics/benchmark_job_definitions.txt)

echo "../tests/PumlForTesting/PumlRegression/SimpleSequenceJob.puml" | xargs python ../bin/plus2json.pyz --play --msgbroker localhost:9092 --topic default.AEReception_service0 --rate 500 --num-events 150000
echo "Done."
#sleep 60
#echo "Running benchmark calculations..."
#python ../metrics/benchmark.py --msgbroker localhost:9092 --topic default.BenchmarkingProbe_service0
#echo "Done."
