#!/bin/bash

set -e
# set -x

. ./.env
. ./functions.sh

# These are safe to delete, even if they don't exist
kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    Job/recipe-producer-v1 \
    Job/recipe-producer-v1-invalid \
    Job/recipe-producer-v2 \
        || true

# These are safe to delete, even if they don't exist
kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    KafkaTopic/raw-recipes-dlq \
    KafkaTopic/raw-recipes \
    KafkaTopic/raw-orders \
    KafkaTopic/enriched-orders \
    || true

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    Deployment/recipe-consumer-v1 \
    Deployment/recipe-consumer-v2 \
    || true

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    Deployment/order-consumer \
    Deployment/order-producer \
    || true