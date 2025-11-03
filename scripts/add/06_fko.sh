#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

#### Helm
# FKO

# FKO: disable cert-manager cause it's super flaky
helm upgrade --install cp-flink-kubernetes-operator \
    confluentinc/flink-kubernetes-operator \
    --set operatorPod.resources.requests.cpu=100m \
    --set webhook.create=false \
    --namespace "${NAMESPACE}" \
    --version ${FKO_VERSION}

    # --set watchNamespaces=\{"${NAMESPACE}"\} \
