#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

###### ./assets/manifests/flink includes these objects:

export MANIFEST_DIR=./assets/manifests/flink

deploy_manifests ${MANIFEST_DIR}
