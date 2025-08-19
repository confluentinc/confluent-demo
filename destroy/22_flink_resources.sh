#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

kubectl -n ${NAMESPACE} delete \
    FlinkApplication/state-machine-example \
    FlinkEnvironment/${NAMESPACE} \
        || true

# Todo - check for removal of all FA/FE
clean_up_flinkdeployment
sleep 2
