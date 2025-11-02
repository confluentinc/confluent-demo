#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

# Create certificate secret for ksqldb
create_certificate_secret ksqldb

###### ./assets/demos/pipeline/infrastructure includes these objects:
# * ksqldb (CFK CR)
# * kibana (Deployment, Service, Ingress)
# * elasticsearch (Deployment, Service, Ingress)
# * KafkaTopic 'wikipedia.parsed'

export MANIFEST_DIR=./assets/demos/pipeline/infrastructure

deploy_manifests ${MANIFEST_DIR}

wait_for_pod app=elasticsearch
wait_for_pod app=kibana
wait_for_pod app=ksqldb
wait_for_pod app=connect
