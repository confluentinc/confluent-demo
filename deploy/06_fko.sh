#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

#### Helm
# FKO

# TODO: Update CRDs?

# FKO: disable cert-manager cause it's super flaky
helm upgrade --install cp-flink-kubernetes-operator \
    confluentinc/flink-kubernetes-operator \
    --set operatorPod.resources.requests.cpu=100m \
    --set watchNamespaces=\{"${NAMESPACE}"\} \
    --set webhook.create=false \
    --namespace ${NAMESPACE} \
    --version ${FKO_VERSION}
