#!/bin/bash

set -euo pipefail
# set -x

. ./.env
. ./scripts/functions.sh

if [[ $(kubectl get namespace | grep "${NAMESPACE}" | wc -l) -lt 1 ]]; then
    echo "Namespace ${NAMESPACE} does not exist, skipping pipeline demo deletion"
    exit 0
fi

if [[ $(kubectl -n "${NAMESPACE}" get pod -l app=connect | grep -E "1/1.*Running" | wc -l) -lt 1 ]]; then
    echo "Connect is not running, removing finalizers to skip validation"
    remove_finalizer "${NAMESPACE}" connector/elasticsearch-sink
    remove_finalizer "${NAMESPACE}" connector/wikipedia-sse-source
fi

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    connector/elasticsearch-sink \
    connector/wikipedia-sse-source

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    KafkaTopic/WIKIPEDIABOT

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    ksqldb/ksqldb

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    Deployment/elasticsearch \
    Deployment/kibana \
    Service/elasticsearch \
    Service/kibana \
    Ingress/elasticsearch \
    Ingress/kibana

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    secret \
        tls-ksqldb