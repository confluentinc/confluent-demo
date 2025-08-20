#!/bin/bash

set -e
set -x

. ./.env
. ./scripts/functions.sh

###### ./assets/manifests/topics includes these objects:

export MANIFEST_DIR=./assets/manifests/topics

deploy_manifests ${MANIFEST_DIR}
