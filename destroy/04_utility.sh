#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

kubectl -n ${NAMESPACE} delete \
    statefulset/confluent-utility \
        || true

kubectl -n ${NAMESPACE} delete \
    configmap utility-config \
        || true