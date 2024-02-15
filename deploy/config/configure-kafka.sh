#!/bin/bash

# configure topics
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic AsyncLogger_service0 --add-config retention.ms=5000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic AsyncLogger_service1 --add-config retention.ms=5000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic AsyncLogger_service2 --add-config retention.ms=5000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic AsyncLogger_service3 --add-config retention.ms=5000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic AsyncLogger_service4 --add-config retention.ms=5000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic AsyncLogger_service5 --add-config retention.ms=5000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic JobManagement_service0 --add-config retention.ms=60000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic JobManagement_service1 --add-config retention.ms=60000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic JobManagement_service2 --add-config retention.ms=60000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic JobManagement_service3 --add-config retention.ms=60000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic JobManagement_service4 --add-config retention.ms=60000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic JobManagement_service5 --add-config retention.ms=60000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic JobManagement_service6 --add-config retention.ms=60000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic AEOrdering_service0 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic AEOrdering_service1 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic AEOrdering_service2 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic AEOrdering_service3 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic AEOrdering_service4 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic AEOrdering_service5 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic AEOrdering_service6 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic AEOrdering_service7 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic AEOrdering_service8 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic AEOrdering_service9 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic AESequenceDC_service12 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic AESequenceDC_service31 --add-config retention.ms=300000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic IStore_service0 --add-config retention.ms=30000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic IStore_service1 --add-config retention.ms=30000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic IStore_service2 --add-config retention.ms=30000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic IStore_service3 --add-config retention.ms=30000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic IStore_service4 --add-config retention.ms=30000
/opt/kafka/bin/kafka-configs.sh --alter --bootstrap-server kafka:9093 --topic BenchmarkingProbe_service0 --add-config retention.ms=6000000
