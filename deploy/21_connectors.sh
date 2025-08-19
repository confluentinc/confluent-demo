#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

###### ./assets/manifests/connectors includes these objects:

export MANIFEST_DIR=./assets/manifests/connectors

deploy_manifests ${MANIFEST_DIR}
