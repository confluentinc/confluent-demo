#!/bin/bash

set -euo pipefail
# set -x

. ./.env
. ./scripts/functions.sh

if [[ $(kubectl get namespace | grep "${NAMESPACE}" | wc -l) -lt 1 ]]; then
    echo "Namespace ${NAMESPACE} does not exist, skipping topics deletion"
    exit 0
fi

set +e
timeout 15s kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    KafkaTopic/shoe-customers \
    KafkaTopic/shoe-products \
    KafkaTopic/shoe-orders


RESULT=${?}
set -e

if [[ ${RESULT} -eq 124 ]]; then
    echo "Timed out, removing finalizers and deleting topics forcefully"
    remove_finalizer "${NAMESPACE}" KafkaTopic/shoe-customers
    remove_finalizer "${NAMESPACE}" KafkaTopic/shoe-products
    remove_finalizer "${NAMESPACE}" KafkaTopic/shoe-orders

    kubectl -n "${NAMESPACE}" delete \
        --ignore-not-found=true \
        KafkaTopic/shoe-customers \
        KafkaTopic/shoe-products \
        KafkaTopic/shoe-orders \
        --force
else
    # echo "${RESULT}"
    echo "Successfully deleted topics"
fi
