#!/bin/bash

set -euo pipefail
# set -x

. ./.env
. ./scripts/functions.sh

if [[ $(kubectl get namespace | grep "${KEYCLOAK_NAMESPACE}" | wc -l) -lt 1 ]]; then
    echo "Namespace ${KEYCLOAK_NAMESPACE} does not exist, skipping Keycloak deletion"
    exit 0
fi

# From manifests
kubectl -n "${KEYCLOAK_NAMESPACE}" delete \
    --ignore-not-found=true \
    ingress/keycloak \
    ingress/keycloak-insecure \
    service/keycloak \
    service/keycloak-discovery \
    statefulset/keycloak \
    deployment/postgres \
    service/postgres

sleep 10

# Manually created
kubectl -n "${KEYCLOAK_NAMESPACE}" delete \
    --ignore-not-found=true \
    secret/tls-keycloak \
    configmap/keycloak-realm

kubectl delete namespace "${KEYCLOAK_NAMESPACE}" \
    --ignore-not-found=true
