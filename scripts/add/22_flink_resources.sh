#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

###### ./assets/manifests/flink includes these objects:

export MANIFEST_DIR=./assets/manifests/flink

deploy_manifests ${MANIFEST_DIR}
