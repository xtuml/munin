#!/bin/bash

# configure topics
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AsyncLogger_service0 --add-config retention.ms=5000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AEReception_service2 --add-config retention.ms=60000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AEOrdering_service2 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AESequenceDC_service31 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.IStore_service2 --add-config retention.ms=30000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.IStore_service3 --add-config retention.ms=30000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.IStore_service4 --add-config retention.ms=30000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.BenchmarkingProbe_service0 --add-config retention.ms=6000000
