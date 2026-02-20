#!/bin/bash

set -euo pipefail
# set -x

. ./.env
. ./scripts/functions.sh

if [[ $(kubectl get namespace | grep "${ENVOY_GATEWAY_NAMESPACE}" | wc -l) -lt 1 ]]; then
    echo "Namespace ${ENVOY_GATEWAY_NAMESPACE} does not exist, skipping Envoy Gateway deletion"
    exit 0
fi

kubectl -n "${ENVOY_GATEWAY_NAMESPACE}" delete \
    --ignore-not-found=true \
    Gateway/envoy-gateway \
    GatewayClass/envoy-gateway

helm uninstall envoy-gateway \
    --namespace ${ENVOY_GATEWAY_NAMESPACE}

kubectl delete namespace ${ENVOY_GATEWAY_NAMESPACE} \
    --ignore-not-found=true
