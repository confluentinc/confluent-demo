#!/bin/bash

set -euo pipefail
# set -x

. ./.env
. ./scripts/functions.sh

if [[ $(kubectl get namespace | grep "${NAMESPACE}" | wc -l) -lt 1 ]]; then
    echo "Namespace ${NAMESPACE} does not exist, skipping topics deletion"
    exit 0
fi

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    KafkaTopic/shoe-customers \
    KafkaTopic/shoe-products \
    KafkaTopic/shoe-orders
