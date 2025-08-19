#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

helm -n ${NAMESPACE} uninstall cmf

sleep 2

kubectl -n ${NAMESPACE} delete \
    ClusterRole/${CMF_SERVICE_ACCOUNT} \
    ClusterRoleBinding/${CMF_SERVICE_ACCOUNT} \
    CMFRestClass/default \
    Role/${CMF_SERVICE_ACCOUNT} \
    RoleBinding/${CMF_SERVICE_ACCOUNT} \
    ServiceAccount/${CMF_SERVICE_ACCOUNT} \
        || true

kubectl -n ${NAMESPACE} delete \
    Secret/tls-cmf \
    Secret/cmf-encryption-key \
        || true
