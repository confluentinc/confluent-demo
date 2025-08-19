#!/bin/bash

# set -e
# set -x

. ./.env
. ./functions.sh

helm uninstall ingress-nginx \
    --namespace ${INGRESS_NGINX_NAMESPACE}

kubectl delete namespace ${INGRESS_NGINX_NAMESPACE} \
        || true