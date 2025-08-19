#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

# gt 2: ignore header lines and CMF pod
while [[ $(kubectl -n ${NAMESPACE} get pods -l platform.confluent.io/origin=flink | wc -l ) -gt 2 ]];
do
    echo "Waiting 10s for FKO-managed pods to terminate"
    kubectl -n ${NAMESPACE} get pods -l platform.confluent.io/origin=flink
    sleep 10
done

helm -n ${NAMESPACE} uninstall cp-flink-kubernetes-operator
