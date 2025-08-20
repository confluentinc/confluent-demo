#!/bin/bash

set -e
# set -x

. ./.env
. ./scripts/functions.sh

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    FlinkApplication/state-machine-example \
    FlinkEnvironment/${NAMESPACE} \
        || true

# Todo - check for removal of all FA/FE
clean_up_flinkdeployment
sleep 2
