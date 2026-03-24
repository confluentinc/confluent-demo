#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

###### manifests/basic includes these objects:

# KRaftController/kraft

# Kafka/kafka
# TLSRoute/kafka-bootstrap
# TLSRoute/kafka-0
# TLSRoute/kafka-1
# TLSRoute/kafka-2
# Service/kafka-bootstrap

# KafkaRestClass/default

# SchemaRegistry/schemaregistry
# TLSRoute/schemaregistry

# Connect/connect

# ControlCenter/controlcenter
# TLSRoute/controlcenter

# KafkaTopic/shoe-customers
# KafkaTopic/shoe-products
# KafkaTopic/shoe-orders

export MANIFEST_DIR=./assets/infrastructure/manifests/cfk/${MODE}

deploy_manifests ${MANIFEST_DIR}
