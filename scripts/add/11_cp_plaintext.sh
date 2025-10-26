#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

###### manifests/basic includes these objects:
# StatefulSet/confluent-utility

# KRaftController/kraft

# Kafka/kafka
# Ingress/kafka
# Service/kafka-bootstrap
# KafkaRestClass/default

# SchemaRegistry/schemaregistry
# Ingress/schemaregistry

# Connect/connect

# ControlCenter/controlcenter
# Ingress/controlcenter

# KafkaTopic/shoe-customers
# KafkaTopic/shoe-products
# KafkaTopic/shoe-orders

export MANIFEST_DIR=./assets/manifests/cfk/plaintext

deploy_manifests ${MANIFEST_DIR}
