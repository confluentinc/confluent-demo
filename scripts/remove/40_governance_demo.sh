#!/bin/bash

set -euo pipefail
# set -x

. ./.env
. ./scripts/functions.sh

if [[ $(kubectl get namespace | grep "${NAMESPACE}" | wc -l) -lt 1 ]]; then
    echo "Namespace ${NAMESPACE} does not exist, skipping governance demo deletion"
    exit 0
fi

# These are safe to delete, even if they don't exist
kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    Job/recipe-producer-v1 \
    Job/recipe-producer-v1-invalid \
    Job/recipe-producer-v2

# These are safe to delete, even if they don't exist
kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    KafkaTopic/raw-recipes-dlq \
    KafkaTopic/raw-recipes \
    KafkaTopic/raw-orders \
    KafkaTopic/enriched-orders

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    Deployment/recipe-consumer-v1 \
    Deployment/recipe-consumer-v2

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    Deployment/order-consumer \
    Deployment/order-producer