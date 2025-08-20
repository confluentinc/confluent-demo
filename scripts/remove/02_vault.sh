#!/bin/bash

# set -e
# set -x

. ./.env
. ./scripts/functions.sh

kubectl -n ${VAULT_NAMESPACE} delete \
    --ignore-not-found=true \
    Ingress/vault

helm uninstall vault \
    --namespace ${VAULT_NAMESPACE}

kubectl delete namespace ${VAULT_NAMESPACE} \
    --ignore-not-found=true \
        || true
