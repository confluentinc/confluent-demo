#!/bin/bash

set -euo pipefail
# set -x

. ./.env
. ./scripts/functions.sh

if [[ $(kubectl get namespace | grep "${NAMESPACE}" | wc -l) -lt 1 ]]; then
    echo "Namespace ${NAMESPACE} does not exist, skipping CP certs deletion"
    exit 0
fi

# Basic infra
kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    secret \
        tls-kraft \
        tls-kafka \
        tls-connect \
        tls-controlcenter \
        tls-schemaregistry \
        tls-client \
        mds-token
