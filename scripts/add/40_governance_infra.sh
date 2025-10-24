#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

###### ./assets/manifests/topics includes these objects:

export MANIFEST_DIR=./assets/demo/governance/topics

deploy_manifests ${MANIFEST_DIR}

export MODE=$(cat ./local/mode)
kubectl create configmap governance-config \
    --from-file ./assets/demo/governance/config/${MODE} \
    -n "${NAMESPACE}" \
    --save-config \
    --dry-run=client \
    -oyaml > ${LOCAL_DIR}/governance-config.yaml

kubectl -n "${NAMESPACE}" apply -f ${LOCAL_DIR}/governance-config.yaml