#!/bin/bash

# set -e
# set -x

. ./.env
. ./functions.sh

kubectl -n ${VAULT_NAMESPACE} delete \
    Ingress/vault

helm uninstall vault \
    --namespace ${VAULT_NAMESPACE}

kubectl delete namespace ${VAULT_NAMESPACE} \
        || true
