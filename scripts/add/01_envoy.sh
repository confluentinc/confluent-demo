#!/bin/bash

## INSTALL Envoy Gateway Controller

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

export MANIFEST_DIR=./assets/infrastructure/manifests/gateway

kubectl create namespace ${ENVOY_GATEWAY_NAMESPACE} --dry-run=client -oyaml | kubectl apply -f -

# Copy CA certificates
copy_ca_certs

create_certificate_secret gateway ${ENVOY_GATEWAY_NAMESPACE}

# Has to be a TLS secret, not a generic secret
kubectl -n ${ENVOY_GATEWAY_NAMESPACE} create secret tls \
    tls-envoy-gateway \
    --cert=${CERT_DIR}/gateway.pem \
    --key=${CERT_DIR}/gateway-key.pem \
    --save-config \
    --dry-run=client \
    -oyaml | kubectl apply -f -

helm upgrade --install envoy-gateway \
    oci://docker.io/envoyproxy/gateway-helm \
    --version ${ENVOY_GATEWAY_VERSION} \
    --namespace ${ENVOY_GATEWAY_NAMESPACE}

kubectl wait --timeout=5m -n ${ENVOY_GATEWAY_NAMESPACE} deployment/envoy-gateway --for=condition=Available

deploy_manifests ${MANIFEST_DIR}
