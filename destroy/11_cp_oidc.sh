#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

# From manifests
kubectl -n ${NAMESPACE} delete \
    KafkaTopic/shoe-customers \
    KafkaTopic/shoe-products \
    KafkaTopic/shoe-orders \
        || true

kubectl -n ${NAMESPACE} delete \
    controlcenter/controlcenter \
    ingress/controlcenter \
        || true

kubectl -n ${NAMESPACE} delete \
    connect/connect \
        || true

kubectl -n ${NAMESPACE} delete \
    schemaregistry/schemaregistry \
    ingress/schemaregistry \
        || true

kubectl -n ${NAMESPACE} delete \
    ConfluentRolebinding/manual-admin \
    ConfluentRolebinding/manual-admin-connect \
    ConfluentRolebinding/manual-admin-sr \
    ConfluentRolebinding/manual-controlcenter \
    ConfluentRolebinding/manual-controlcenter-connect \
    ConfluentRolebinding/manual-controlcenter-sr \
    ConfluentRoleBinding/manual-connect-sr \
        || true

kubectl -n ${NAMESPACE} delete \
    kafkarestclass/default \
        || true

kubectl -n ${NAMESPACE} delete \
    kafka/kafka \
    service/kafka-bootstrap \
    ingress/kafka \
        || true

kubectl -n ${NAMESPACE} delete \
    kraftcontroller/kraft

kubectl -n ${NAMESPACE} delete \
    statefulset/confluent-utility \
        || true

kubectl -n ${NAMESPACE} delete \
    secret \
        oauth-jaas \
        sso-oauth-jaas \
        kafka-oauth-jaas \
        schemaregistry-oauth-jaas \
        connect-oauth-jaas \
        controlcenter-oauth-jaas \
        cmf-oauth-jaas \
        || true

# gt 2: ignore header lines and CFK operator pod
while [[ $(kubectl -n ${NAMESPACE} get pods -l confluent-platform=true | wc -l ) -gt 2 ]];
do
    echo "Waiting 10s for CFK-managed pods to terminate"
    kubectl -n ${NAMESPACE} get pods -l confluent-platform=true
    sleep 10
done
