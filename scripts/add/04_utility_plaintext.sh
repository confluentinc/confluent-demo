#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

mkdir -p ${LOCAL_DIR}/config/basic
mkdir -p ${LOCAL_DIR}/config/governance
mkdir -p ${LOCAL_DIR}/config/pipeline

rm ${LOCAL_DIR}/config/basic/* || true
rm ${LOCAL_DIR}/config/governance/* || true
rm ${LOCAL_DIR}/config/pipeline/* || true

for f in ./assets/config/basic-plaintext/*; do
    envsubst < ${f} > ${LOCAL_DIR}/config/basic/$(basename ${f})
done

for f in ./assets/config/governance/*; do
    # Governance configs have a bunch of '$'' in them, so we can't use envsubst
    # envsubst < ${f} > ${LOCAL_DIR}/config/governance/$(basename ${f})
    cp ${f} ${LOCAL_DIR}/config/governance/$(basename ${f})
done

for f in ./assets/config/pipeline/*; do
    envsubst < ${f} > ${LOCAL_DIR}/config/pipeline/$(basename ${f})
done

kubectl create configmap utility-config \
    --from-file ${LOCAL_DIR}/config/basic \
    -n "${NAMESPACE}" \
    --save-config \
    --dry-run=client \
    -oyaml > ${LOCAL_DIR}/utility-config.yaml

kubectl -n "${NAMESPACE}" apply -f ${LOCAL_DIR}/utility-config.yaml

kubectl create configmap utility-governance-config \
    --from-file ${LOCAL_DIR}/config/governance \
    -n "${NAMESPACE}" \
    --save-config \
    --dry-run=client \
    -oyaml > ${LOCAL_DIR}/utility-governance-config.yaml

kubectl -n "${NAMESPACE}" apply -f ${LOCAL_DIR}/utility-governance-config.yaml

kubectl create configmap utility-pipeline-config \
    --from-file ${LOCAL_DIR}/config/pipeline \
    -n "${NAMESPACE}" \
    --save-config \
    --dry-run=client \
    -oyaml > ${LOCAL_DIR}/utility-pipeline-config.yaml

kubectl -n "${NAMESPACE}" apply -f ${LOCAL_DIR}/utility-pipeline-config.yaml

export MANIFEST_DIR=./assets/manifests/utility/plaintext

deploy_manifests ${MANIFEST_DIR}
