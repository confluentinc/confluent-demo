#!/bin/bash

set -euo pipefail
# set -x

. ./.env
. ./scripts/functions.sh

if [[ $(kubectl get namespace | grep "${NAMESPACE}" | wc -l) -lt 1 ]]; then
    echo "Namespace ${NAMESPACE} does not exist, skipping utility deletion"
    exit 0
fi

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    statefulset/confluent-utility

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    configmap utility-config \
    configmap utility-governance-config \
    configmap utility-pipeline-config