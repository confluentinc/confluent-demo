#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

###### ./assets/resources/topics includes these objects:

export MANIFEST_DIR=./assets/resources/topics

deploy_manifests ${MANIFEST_DIR}
