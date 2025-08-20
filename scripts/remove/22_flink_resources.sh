#!/bin/bash

set -e
# set -x

. ./.env
. ./scripts/functions.sh

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    FlinkApplication/state-machine-example \
    FlinkEnvironment/${NAMESPACE}

clean_up_flinkdeployment
sleep 2
