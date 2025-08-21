#!/bin/bash

set -euo pipefail
# set -x

. ./.env
. ./scripts/functions.sh

if [[ $(kubectl get namespace | grep "${NAMESPACE}" | wc -l) -lt 1 ]]; then
    echo "Namespace ${NAMESPACE} does not exist, skipping CMF deletion"
    exit 0
fi

helm -n "${NAMESPACE}" uninstall cmf

sleep 2

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    CMFRestClass/default \
    Role/${CMF_SERVICE_ACCOUNT} \
    RoleBinding/${CMF_SERVICE_ACCOUNT} \
    ServiceAccount/${CMF_SERVICE_ACCOUNT}

# These resources are not namespaced
kubectl delete \
    --ignore-not-found=true \
    ClusterRole/${CMF_SERVICE_ACCOUNT} \
    ClusterRoleBinding/${CMF_SERVICE_ACCOUNT}

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    Secret/tls-cmf \
    Secret/cmf-encryption-key
