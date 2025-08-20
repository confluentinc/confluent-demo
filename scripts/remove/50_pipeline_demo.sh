#!/bin/bash

. ./.env
. ./scripts/functions.sh

# TODO: Refactor

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    connector/elasticsearch-sink \
    connector/wikipedia-sse-source \
    || true

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    KafkaTopic/WIKIPEDIABOT \
    || true

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    ksqldb/ksqldb \
    || true

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    Deployment/elasticsearch \
    Deployment/kibana \
    Service/elasticsearch \
    Service/kibana \
    Ingress/elasticsearch \
    Ingress/kibana \
    || true

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    secret \
        tls-ksqldb \
    || true