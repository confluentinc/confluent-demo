#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

###### ./assets/demos/governance/topics includes these objects:

export MANIFEST_DIR=./assets/demos/governance/topics

deploy_manifests ${MANIFEST_DIR}

kubectl create configmap governance-config \
    --from-file ./assets/demos/governance/config/${MODE} \
    -n "${NAMESPACE}" \
    --save-config \
    --dry-run=client \
    -oyaml > ${LOCAL_DIR}/governance-config.yaml

kubectl -n "${NAMESPACE}" apply -f ${LOCAL_DIR}/governance-config.yaml
