#!/bin/bash

set -e
set -x

. ./.env
. ./scripts/functions.sh

# TODO: Decide if we want to deploy ksqlDB as initial CP deployment

# Create certificate secret for ksqldb
create_certificate_secret ksqldb

###### ./assets/demo/pipeline/manifests includes these objects:
# * ksqldb (CFK CR)
# * kibana (Deployment, Service, Ingress)
# * elasticsearch (Deployment, Service, Ingress)
# * KafkaTopic 'wikipedia.parsed'

export MANIFEST_DIR=./assets/demo/pipeline/manifests

deploy_manifests ${MANIFEST_DIR}

wait_for_pod app=elasticsearch
wait_for_pod app=kibana
wait_for_pod app=ksqldb
wait_for_pod app=connect