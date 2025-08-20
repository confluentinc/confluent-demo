#!/bin/bash

set -e
set -x

. ./.env
. ./scripts/functions.sh

kubectl create configmap utility-config \
    --from-file ./assets/config/basic \
    -n ${NAMESPACE} \
    --save-config \
    --dry-run=client \
    -oyaml > ${LOCAL_DIR}/utility-config.yaml

kubectl -n ${NAMESPACE} apply -f ${LOCAL_DIR}/utility-config.yaml

kubectl create configmap utility-governance-config \
    --from-file ./assets/config/governance \
    -n ${NAMESPACE} \
    --save-config \
    --dry-run=client \
    -oyaml > ${LOCAL_DIR}/utility-governance-config.yaml

kubectl -n ${NAMESPACE} apply -f ${LOCAL_DIR}/utility-governance-config.yaml

kubectl create configmap utility-pipeline-config \
    --from-file ./assets/config/pipeline \
    -n ${NAMESPACE} \
    --save-config \
    --dry-run=client \
    -oyaml > ${LOCAL_DIR}/utility-pipeline-config.yaml

kubectl -n ${NAMESPACE} apply -f ${LOCAL_DIR}/utility-pipeline-config.yaml

export MANIFEST_DIR=./assets/manifests/utility

deploy_manifests ${MANIFEST_DIR}
