#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

###### ./assets/manifests/topics includes these objects:

export MANIFEST_DIR=./assets/manifests/topics

deploy_manifests ${MANIFEST_DIR}
