#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

###### Creates / Installs the following:

### Helm Charts:
# CFK

### Other
# CRDs <- not cleaned up
# Adds repos for helm <- todo custom repo name

# Install Ingress Nginx and Confluent Helm Repos
helm repo add confluentinc https://packages.confluent.io/helm --force-update
helm repo update

# Create namespaces if they don't exist
kubectl create namespace ${NAMESPACE} --dry-run=client -oyaml | kubectl apply -f -

# Upgrade CFK CRDs
helm show crds confluentinc/confluent-for-kubernetes | kubectl apply --server-side=true -f -

# CFK
helm upgrade --install confluent-for-kubernetes \
    confluentinc/confluent-for-kubernetes \
    --namespace ${OPERATOR_NAMESPACE} \
    --set namespaced=true \
    --set enableCMFDay2Ops=true \
    --set namespaceList=\{"${NAMESPACE}","${OPERATOR_NAMESPACE}"\} \
    --version ${CFK_CHART_VERSION}
