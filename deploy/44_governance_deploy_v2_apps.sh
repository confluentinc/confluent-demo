#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

export MANIFEST_DIR=./assets/demo/governance/applications

deploy_single_manifest ${MANIFEST_DIR} recipe-producer-Job-v2.yaml
deploy_single_manifest ${MANIFEST_DIR} recipe-consumer-Deployment-v2.yaml