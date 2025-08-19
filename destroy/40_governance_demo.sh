#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

# These are safe to delete, even if they don't exist
kubectl -n ${NAMESPACE} delete Job/recipe-producer-v1 || true
kubectl -n ${NAMESPACE} delete Job/recipe-producer-v1-invalid || true
kubectl -n ${NAMESPACE} delete Job/recipe-producer-v2 || true

# These are safe to delete, even if they don't exist
kubectl -n ${NAMESPACE} delete \
    KafkaTopic/raw-recipes \
    KafkaTopic/raw-recipes-dlq \
    KafkaTopic/raw-orders \
    KafkaTopic/enriched-orders || true

kubectl -n ${NAMESPACE} delete \
    Deployment/recipe-consumer-v1 \
    Deployment/recipe-consumer-v2 || true

kubectl -n ${NAMESPACE} delete \
    Deployment/order-consumer \
    Deployment/order-producer || true