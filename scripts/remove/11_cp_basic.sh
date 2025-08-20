#!/bin/bash

set -e
# set -x

. ./.env
. ./scripts/functions.sh

# From manifests/basic
kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    KafkaTopic/shoe-customers \
    KafkaTopic/shoe-products \
    KafkaTopic/shoe-orders

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    controlcenter/controlcenter \
    ingress/controlcenter

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    connect/connect

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    schemaregistry/schemaregistry \
    ingress/schemaregistry

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    kafkarestclass/default

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    kafka/kafka \
    service/kafka-bootstrap \
    ingress/kafka

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    kraftcontroller/kraft

# gt 2: ignore header lines and CFK operator pod
while [[ $(kubectl -n ${NAMESPACE} get pods -l confluent-platform=true | wc -l ) -gt 2 ]];
do
    echo "Waiting 10s for CFK-managed pods to terminate"
    kubectl -n ${NAMESPACE} get pods -l confluent-platform=true
    sleep 10
done
