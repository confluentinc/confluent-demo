#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

###### ./assets/resources/flink includes these objects:

for NS in ${FLINK_DEV_NAMESPACE} ${FLINK_PROD_NAMESPACE}; do
    kubectl create namespace "${NS}" --dry-run=client -oyaml | kubectl apply -f -

    create_certificate_secret client ${NS}

    export MANIFEST_DIR=./assets/resources/flink/${NS}
    deploy_manifests ${MANIFEST_DIR}
done
