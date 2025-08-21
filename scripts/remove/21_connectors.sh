#!/bin/bash

set -euo pipefail
# set -x

. ./.env
. ./scripts/functions.sh

if [[ $(kubectl get namespace | grep "${NAMESPACE}" | wc -l) -lt 1 ]]; then
    echo "Namespace ${NAMESPACE} does not exist, skipping connectors deletion"
    exit 0
fi

if [[ $(kubectl -n "${NAMESPACE}" get pod -l app=connect | grep "1/1" | wc -l) -lt 1 ]]; then
    echo "Connect is not running, removing finalizers to skip validation"
    remove_finalizer "${NAMESPACE}" connector/shoe-customers
    remove_finalizer "${NAMESPACE}" connector/shoe-products
    remove_finalizer "${NAMESPACE}" connector/shoe-orders
fi

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    Connector/shoe-customers \
    Connector/shoe-products \
    Connector/shoe-orders
