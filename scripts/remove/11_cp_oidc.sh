#!/bin/bash

set -euo pipefail
# set -x

. ./.env
. ./scripts/functions.sh

if [[ $(kubectl get namespace | grep "${NAMESPACE}" | wc -l) -lt 1 ]]; then
    echo "Namespace ${NAMESPACE} does not exist, skipping CP OIDC deletion"
    exit 0
fi

# From manifests
kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    KafkaTopic/shoe-customers \
    KafkaTopic/shoe-products \
    KafkaTopic/shoe-orders

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    controlcenter/controlcenter \
    ingress/controlcenter

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    connect/connect

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    schemaregistry/schemaregistry \
    ingress/schemaregistry

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    ConfluentRolebinding/manual-admin \
    ConfluentRolebinding/manual-admin-connect \
    ConfluentRolebinding/manual-admin-sr \
    ConfluentRolebinding/manual-controlcenter \
    ConfluentRolebinding/manual-controlcenter-connect \
    ConfluentRolebinding/manual-controlcenter-sr \
    ConfluentRoleBinding/manual-connect-sr

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    KafkaRestClass/default

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    kafka/kafka \
    service/kafka-bootstrap \
    ingress/kafka

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    kraftcontroller/kraft

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    statefulset/confluent-utility

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    secret \
        oauth-jaas \
        sso-oauth-jaas \
        kafka-oauth-jaas \
        schemaregistry-oauth-jaas \
        connect-oauth-jaas \
        controlcenter-oauth-jaas \
        cmf-oauth-jaas

# gt 2: ignore header lines and CFK operator pod
while [[ $(kubectl -n "${NAMESPACE}" get pods -l confluent-platform=true | wc -l ) -gt 2 ]];
do
    echo "Waiting 10s for CFK-managed pods to terminate"
    kubectl -n "${NAMESPACE}" get pods -l confluent-platform=true
    sleep 10
done
