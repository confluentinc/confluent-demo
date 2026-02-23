#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

###### manifests/basic includes these objects:
# StatefulSet/confluent-utility

# KRaftController/kraft

# Kafka/kafka
# HTTPRoute/kafka
# Service/kafka-bootstrap
# KafkaRestClass/default

# SchemaRegistry/schemaregistry
# HTTPRoute/schemaregistry

# Connect/connect

# ControlCenter/controlcenter
# HTTPRoute/controlcenter

# KafkaTopic/shoe-customers
# KafkaTopic/shoe-products
# KafkaTopic/shoe-orders

export MANIFEST_DIR=./assets/infrastructure/manifests/cfk/${MODE}

deploy_manifests ${MANIFEST_DIR}
