#!/bin/bash

###### Governance Demo Infra

# Creates these topics:
# * KafkaTopic/enriched.orders
# * KafkaTopic/raw.orders
# * KafkaTopic/raw.recipes
# * KafkaTopic/raw.recipes.dlq

# Creates a ConfigMap with these files:
# * orders-consumer.properties
# * orders-producer.properties
# * recipes-consumer.v1.properties
# * recipes-consumer.v2.properties
# * recipes-producer.v1.properties
# * recipes-producer.v2.properties

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh


export MANIFEST_DIR=./assets/demos/governance/topics

deploy_manifests ${MANIFEST_DIR}

kubectl create configmap governance-config \
    --from-file ./assets/demos/governance/config/${MODE} \
    -n "${NAMESPACE}" \
    --save-config \
    --dry-run=client \
    -oyaml > ${LOCAL_DIR}/governance-config.yaml

kubectl -n "${NAMESPACE}" apply -f ${LOCAL_DIR}/governance-config.yaml
