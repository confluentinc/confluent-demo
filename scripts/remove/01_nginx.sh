#!/bin/bash

set -euo pipefail
# set -x

. ./.env
. ./scripts/functions.sh

if [[ $(kubectl get namespace | grep "${INGRESS_NGINX_NAMESPACE}" | wc -l) -lt 1 ]]; then
    echo "Namespace ${INGRESS_NGINX_NAMESPACE} does not exist, skipping NGINX deletion"
    exit 0
fi

helm uninstall ingress-nginx \
    --namespace ${INGRESS_NGINX_NAMESPACE}

# Used for dev; nginx namespace takes a really long time to delete for some reason
if [[ ${KEEP_NGINX:-false} == "true" ]]; then
    echo "Keeping NGINX namespace ${INGRESS_NGINX_NAMESPACE}"
else
    kubectl delete namespace ${INGRESS_NGINX_NAMESPACE} \
        --ignore-not-found=true
fi
