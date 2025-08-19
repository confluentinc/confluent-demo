#!/bin/bash

# set -e
# set -x

. ./.env
. ./functions.sh

helm uninstall confluent-for-kubernetes \
    -n ${NAMESPACE}

sleep 2

kubectl delete namespace ${NAMESPACE} \
        || true
