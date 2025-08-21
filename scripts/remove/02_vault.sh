#!/bin/bash

set -euo pipefail
# set -x

. ./.env
. ./scripts/functions.sh

if [[ $(kubectl get namespace | grep "${VAULT_NAMESPACE}" | wc -l) -lt 1 ]]; then
    echo "Namespace ${VAULT_NAMESPACE} does not exist, skipping Vault deletion"
    exit 0
fi

kubectl -n "${VAULT_NAMESPACE}" delete \
    --ignore-not-found=true \
    Ingress/vault

helm uninstall vault \
    --namespace "${VAULT_NAMESPACE}"

kubectl delete namespace "${VAULT_NAMESPACE}" \
    --ignore-not-found=true
