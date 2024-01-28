#!/bin/bash

# configure topics
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AsyncLogger_service0 --add-config retention.ms=5000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AsyncLogger_service1 --add-config retention.ms=5000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AsyncLogger_service2 --add-config retention.ms=5000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AsyncLogger_service3 --add-config retention.ms=5000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AsyncLogger_service4 --add-config retention.ms=5000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AsyncLogger_service5 --add-config retention.ms=5000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.JobManagement_service0 --add-config retention.ms=60000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.JobManagement_service1 --add-config retention.ms=60000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.JobManagement_service2 --add-config retention.ms=60000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.JobManagement_service3 --add-config retention.ms=60000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.JobManagement_service4 --add-config retention.ms=60000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.JobManagement_service5 --add-config retention.ms=60000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.JobManagement_service6 --add-config retention.ms=60000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AEOrdering_service0 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AEOrdering_service1 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AEOrdering_service2 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AEOrdering_service3 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AEOrdering_service4 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AEOrdering_service5 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AEOrdering_service6 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AEOrdering_service7 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AEOrdering_service8 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AEOrdering_service9 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AESequenceDC_service12 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.AESequenceDC_service31 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.IStore_service0 --add-config retention.ms=30000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.IStore_service1 --add-config retention.ms=30000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.IStore_service2 --add-config retention.ms=30000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.IStore_service3 --add-config retention.ms=30000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.IStore_service4 --add-config retention.ms=30000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic default.BenchmarkingProbe_service0 --add-config retention.ms=6000000
