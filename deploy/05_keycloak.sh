#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

export MANIFEST_DIR=./assets/manifests/keycloak

export CERT_DIR=${LOCAL_DIR}/certs
export CFSSL_DIR=${LOCAL_DIR}/cfssl
mkdir -p $CERT_DIR $CFSSL_DIR

kubectl create namespace ${KEYCLOAK_NAMESPACE} --dry-run=client -oyaml | kubectl apply -f -

# Copy CA certificates
copy_ca_certs

create_certificate_secret keycloak

# Populate keycloak realm configmap
kubectl -n ${KEYCLOAK_NAMESPACE} create configmap keycloak-realm \
        --from-file=realm.json=${MANIFEST_DIR}/realm.json \
        --dry-run=client -oyaml --save-config \
    | kubectl apply -f -

deploy_manifests ${MANIFEST_DIR}
