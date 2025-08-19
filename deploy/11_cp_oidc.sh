#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh


###### manifests/oidc includes these objects:
# StatefulSet/confluent-utility

# KRaftController/kraft

# Kafka/kafka
# Service/kafka-bootstrap
# Ingress/kafka
# KafkaRestClass/default

# SchemaRegistry/schemaregistry
# Ingress/schemaregistry

# Connect/connect

# ControlCenter/controlcenter
# Ingress/controlcenter

# ConfluentRoleBinding.yaml
# - ConfluentRolebinding/manual-admin
# - ConfluentRolebinding/manual-admin-connect
# - ConfluentRolebinding/manual-admin-sr
# - ConfluentRolebinding/manual-controlcenter
# - ConfluentRolebinding/manual-controlcenter-connect
# - ConfluentRolebinding/manual-controlcenter-sr
# - ConfluentRoleBinding/manual-connect-sr

# shoe-KafkaTopics.yaml
# - KafkaTopic/shoe-customers
# - KafkaTopic/shoe-products
# - KafkaTopic/shoe-orders

###### also have these secrets
# oauth-jaas
# sso-oauth-jaas
# kafka-oauth-jaas
# schemaregistry-oauth-jaas
# connect-oauth-jaas
# controlcenter-oauth-jaas
# cmf-oauth-jaas

tee ${LOCAL_DIR}/oauth_jaas.txt <<-'EOF'
clientId=kafka
clientSecret=LpXqoU8bqCqXgNsPKAJIJhQ9WafgWwsj
EOF

tee ${LOCAL_DIR}/sso_oauth_jaas.txt <<-'EOF'
clientId=confluent-sso
clientSecret=Wyt2jq5gzqrONotJ4W7R07OA4yUnnj3l
EOF

tee ${LOCAL_DIR}/kafka_oauth_jaas.txt <<-'EOF'
clientId=kafka
clientSecret=LpXqoU8bqCqXgNsPKAJIJhQ9WafgWwsj
EOF

tee ${LOCAL_DIR}/schemaregistry_oauth_jaas.txt <<-'EOF'
clientId=schemaregistry
clientSecret=1f3725004736c14da0299f25eeb7d853
EOF

tee ${LOCAL_DIR}/connect_oauth_jaas.txt <<-'EOF'
clientId=connect
clientSecret=0d717d281979a760daffe77b397830eb
EOF

tee ${LOCAL_DIR}/controlcenter_oauth_jaas.txt <<-'EOF'
clientId=controlcenter
clientSecret=7dfe814e68561764539f09ae49012ac8
EOF

tee ${LOCAL_DIR}/cmf_oauth_jaas.txt <<-'EOF'
clientId=cmf
clientSecret=5f8e9b2c3d4a8e7b6f0c1d2e3f4a5b6c
EOF

kubectl create -n ${NAMESPACE} secret generic \
    oauth-jaas \
    --from-file=oauth.txt=${LOCAL_DIR}/oauth_jaas.txt \
    --from-file=oidcClientSecret.txt=${LOCAL_DIR}/oauth_jaas.txt \
    --dry-run=client -oyaml --save-config \
    > ${LOCAL_DIR}/oauth-jaas.yaml
kubectl apply -f ${LOCAL_DIR}/oauth-jaas.yaml

kubectl create -n ${NAMESPACE} secret generic \
    sso-oauth-jaas \
    --from-file=oauth.txt=${LOCAL_DIR}/sso_oauth_jaas.txt \
    --from-file=oidcClientSecret.txt=${LOCAL_DIR}/sso_oauth_jaas.txt \
    --dry-run=client -oyaml --save-config \
    > ${LOCAL_DIR}/sso-oauth-jaas.yaml
kubectl apply -f ${LOCAL_DIR}/sso-oauth-jaas.yaml

kubectl create -n ${NAMESPACE} secret generic \
    kafka-oauth-jaas \
    --from-file=oauth.txt=${LOCAL_DIR}/kafka_oauth_jaas.txt \
    --from-file=oidcClientSecret.txt=${LOCAL_DIR}/kafka_oauth_jaas.txt \
    --dry-run=client -oyaml --save-config \
    > ${LOCAL_DIR}/kafka-oauth-jaas.yaml
kubectl apply -f ${LOCAL_DIR}/kafka-oauth-jaas.yaml

kubectl create -n ${NAMESPACE} secret generic \
    schemaregistry-oauth-jaas \
    --from-file=oauth.txt=${LOCAL_DIR}/schemaregistry_oauth_jaas.txt \
    --from-file=oidcClientSecret.txt=${LOCAL_DIR}/schemaregistry_oauth_jaas.txt \
    --dry-run=client -oyaml --save-config \
    > ${LOCAL_DIR}/schemaregistry-oauth-jaas.yaml
kubectl apply -f ${LOCAL_DIR}/schemaregistry-oauth-jaas.yaml

kubectl create -n ${NAMESPACE} secret generic \
    connect-oauth-jaas \
    --from-file=oauth.txt=${LOCAL_DIR}/connect_oauth_jaas.txt \
    --from-file=oidcClientSecret.txt=${LOCAL_DIR}/connect_oauth_jaas.txt \
    --dry-run=client -oyaml --save-config \
    > ${LOCAL_DIR}/connect-oauth-jaas.yaml
kubectl apply -f ${LOCAL_DIR}/connect-oauth-jaas.yaml

kubectl create -n ${NAMESPACE} secret generic \
    controlcenter-oauth-jaas \
    --from-file=oauth.txt=${LOCAL_DIR}/controlcenter_oauth_jaas.txt \
    --from-file=oidcClientSecret.txt=${LOCAL_DIR}/controlcenter_oauth_jaas.txt \
    --dry-run=client -oyaml --save-config \
    > ${LOCAL_DIR}/controlcenter-oauth-jaas.yaml
kubectl apply -f ${LOCAL_DIR}/controlcenter-oauth-jaas.yaml

kubectl create -n ${NAMESPACE} secret generic \
    cmf-oauth-jaas \
    --from-file=oauth.txt=${LOCAL_DIR}/cmf_oauth_jaas.txt \
    --from-file=oidcClientSecret.txt=${LOCAL_DIR}/cmf_oauth_jaas.txt \
    --dry-run=client -oyaml --save-config \
    > ${LOCAL_DIR}/cmf-oauth-jaas.yaml
kubectl apply -f ${LOCAL_DIR}/cmf-oauth-jaas.yaml

export MANIFEST_DIR=./assets/manifests/cfk/oidc
deploy_manifests ${MANIFEST_DIR}
