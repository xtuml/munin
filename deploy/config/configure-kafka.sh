#!/bin/bash

# configure topics
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic JobManagement_service0 --add-config retention.ms=60000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic BenchmarkingProbe_service0 --add-config retention.ms=6000000
