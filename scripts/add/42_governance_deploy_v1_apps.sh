#!/bin/bash

###### Governance Demo Applications - v1
# * Recipe producer v1
# * Recipe consumer v1
# * Order producer
# * Order consumer

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

export MANIFEST_DIR=./assets/demos/governance/applications

deploy_single_manifest ${MANIFEST_DIR} recipe-producer-Job-v1.yaml
deploy_single_manifest ${MANIFEST_DIR} recipe-consumer-Deployment-v1.yaml
deploy_single_manifest ${MANIFEST_DIR} order-producer-Deployment.yaml
deploy_single_manifest ${MANIFEST_DIR} order-consumer-Deployment.yaml
