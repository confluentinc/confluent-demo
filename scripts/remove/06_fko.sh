#!/bin/bash

set -euo pipefail
# set -x

. ./.env
. ./scripts/functions.sh

if [[ $(kubectl get namespace | grep "${NAMESPACE}" | wc -l) -lt 1 ]]; then
    echo "Namespace ${NAMESPACE} does not exist, skipping FKO deletion"
    exit 0
fi

# gt 2: ignore header lines and CMF pod
while [[ $(kubectl -n "${NAMESPACE}" get pods -l platform.confluent.io/origin=flink | wc -l ) -gt 2 ]];
do
    echo "Waiting 10s for FKO-managed pods to terminate"
    kubectl -n "${NAMESPACE}" get pods -l platform.confluent.io/origin=flink
    sleep 10
done

helm -n "${NAMESPACE}" uninstall cp-flink-kubernetes-operator
