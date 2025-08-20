#!/bin/bash

set -e
# set -x

. ./.env
. ./functions.sh

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    statefulset/confluent-utility \
        || true

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    configmap utility-config \
        || true