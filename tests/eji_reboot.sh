#!/bin/bash

# This test establishes a persisted extra-job invariant.
# It then reboots the PV and does not send the source job again.
# As of May 2024, the first EJI user job will fail and then succeed.

P2J="python ../bin/plus2json.pyz"
$P2J -v

echo "Preparing deploy location..."
cd ../deploy
git clean -dxf .
echo "Done."

echo "Generating job definitions..."
echo "../tests/PumlForTesting/PumlRegression/AAExtraJobInvariantSourceJob.puml" | xargs $P2J --job -o config/job_definitions
echo "../tests/PumlForTesting/PumlRegression/ExtraJobInvariantUserJob1.puml" | xargs $P2J --job -o config/job_definitions
echo "Done."

echo "Launching protocol verifier for the first time..."
docker compose down
docker compose up -d
echo "Done."

echo "Seeding extra-job invariant..."
echo "../tests/PumlForTesting/PumlRegression/AAExtraJobInvariantSourceJob.puml" | xargs $P2J --play ${fn} -o reception-incoming
echo "Done."
echo "sleeping 5."
sleep 5

echo "Bringing down and re-launching protocol verifier..."
docker compose down
echo "sleeping 5."
sleep 5
docker compose up -d
echo "Done."

echo "Playing the user job..."
echo "../tests/PumlForTesting/PumlRegression/ExtraJobInvariantUserJob1.puml" | xargs $P2J --play -o reception-incoming
echo "sleeping 20."
sleep 20
echo "../tests/PumlForTesting/PumlRegression/ExtraJobInvariantUserJob1.puml" | xargs $P2J --play -o reception-incoming
echo "Done."

sleep 5
echo "Tearing down protocol verifier..."
docker compose down
echo "Done."
