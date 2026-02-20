#!/bin/bash

## INSTALL Envoy Gateway Controller

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

kubectl create namespace ${ENVOY_GATEWAY_NAMESPACE} --dry-run=client -oyaml | kubectl apply -f -

helm upgrade --install envoy-gateway \
    oci://docker.io/envoyproxy/gateway-helm \
    --version ${ENVOY_GATEWAY_VERSION} \
    --namespace ${ENVOY_GATEWAY_NAMESPACE}

kubectl wait --timeout=5m -n ${ENVOY_GATEWAY_NAMESPACE} deployment/envoy-gateway --for=condition=Available

MANIFEST_DIR=./assets/infrastructure/manifests/gateway
deploy_manifests ${MANIFEST_DIR}
