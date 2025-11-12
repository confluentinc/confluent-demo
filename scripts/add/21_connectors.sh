#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

###### ./assets/resources/connectors includes these objects:

export MANIFEST_DIR=./assets/resources/connectors

deploy_manifests ${MANIFEST_DIR}
