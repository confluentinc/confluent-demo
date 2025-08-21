#!/bin/bash

set -euo pipefail
# set -x

. ./.env
. ./scripts/functions.sh

if [[ $(kubectl get namespace | grep "${NAMESPACE}" | wc -l) -lt 1 ]]; then
    echo "Namespace ${NAMESPACE} does not exist, skipping CFK deletion"
    exit 0
fi

helm uninstall confluent-for-kubernetes \
    -n "${NAMESPACE}"

sleep 2

kubectl delete namespace "${NAMESPACE}" \
    --ignore-not-found=true
