#!/bin/bash

# set -e
# set -x

. ./.env
. ./functions.sh

# From manifests
kubectl -n ${KEYCLOAK_NAMESPACE} delete \
    --ignore-not-found=true \
    ingress/keycloak \
    ingress/keycloak-insecure \
    service/keycloak \
    service/keycloak-discovery \
    statefulset/keycloak \
    deployment/postgres \
    service/postgres \
        || true

sleep 10

# Manually created
kubectl -n ${KEYCLOAK_NAMESPACE} delete \
    --ignore-not-found=true \
    secret/tls-keycloak \
    configmap/keycloak-realm \
        || true

kubectl delete namespace ${KEYCLOAK_NAMESPACE} \
    --ignore-not-found=true \
        || true
