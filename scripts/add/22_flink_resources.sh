#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

###### ./assets/resources/flink includes these objects:

export MANIFEST_DIR=./assets/resources/flink

deploy_manifests ${MANIFEST_DIR}
