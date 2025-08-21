#!/bin/bash

set -euo pipefail
# set -x

. ./.env
. ./scripts/functions.sh

if [[ $(kubectl get namespace | grep "${NAMESPACE}" | wc -l) -lt 1 ]]; then
    echo "Namespace ${NAMESPACE} does not exist, skipping Flink resources deletion"
    exit 0
fi

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    FlinkApplication/state-machine-example \
    FlinkEnvironment/${NAMESPACE}

clean_up_flinkdeployment
sleep 2
