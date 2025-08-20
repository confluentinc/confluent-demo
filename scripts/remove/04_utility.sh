#!/bin/bash

set -e
# set -x

. ./.env
. ./scripts/functions.sh

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    statefulset/confluent-utility

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    configmap utility-config \
    configmap utility-governance-config \
    configmap utility-pipeline-config