#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

export MANIFEST_DIR=./assets/infrastructure/manifests/keycloak

kubectl create namespace ${KEYCLOAK_NAMESPACE} --dry-run=client -oyaml | kubectl apply -f -

# Copy CA certificates
copy_ca_certs

create_certificate_secret keycloak ${KEYCLOAK_NAMESPACE}

# Populate keycloak realm configmap
kubectl -n ${KEYCLOAK_NAMESPACE} create configmap keycloak-realm \
        --from-file=realm.json=${MANIFEST_DIR}/realm.json \
        --dry-run=client -oyaml --save-config \
    | kubectl apply -f -

deploy_manifests ${MANIFEST_DIR}
