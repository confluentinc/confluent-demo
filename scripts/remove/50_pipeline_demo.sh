#!/bin/bash

set -e
# set -x

. ./.env
. ./scripts/functions.sh

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    connector/elasticsearch-sink \
    connector/wikipedia-sse-source

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    KafkaTopic/WIKIPEDIABOT

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    ksqldb/ksqldb

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    Deployment/elasticsearch \
    Deployment/kibana \
    Service/elasticsearch \
    Service/kibana \
    Ingress/elasticsearch \
    Ingress/kibana

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    secret \
        tls-ksqldb