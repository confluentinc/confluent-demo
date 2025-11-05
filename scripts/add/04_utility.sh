#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

mkdir -p ${LOCAL_DIR}/config/utility
mkdir -p ${LOCAL_DIR}/config/governance
mkdir -p ${LOCAL_DIR}/config/pipeline
mkdir -p ${LOCAL_DIR}/config/bin

rm ${LOCAL_DIR}/config/utility/* || true
rm ${LOCAL_DIR}/config/governance/* || true
rm ${LOCAL_DIR}/config/pipeline/* || true
rm ${LOCAL_DIR}/config/bin/* || true

# Mode-specific
for f in ./assets/infrastructure/config/utility/${MODE}/*; do
    envsubst < ${f} > ${LOCAL_DIR}/config/utility/$(basename ${f})
done

# Mode-specific scripts. No envsubst because everything has env variables built in
for f in ./assets/infrastructure/config/bin/${MODE}/*; do
    cp ${f} ${LOCAL_DIR}/config/bin/$(basename ${f})
done

# Generic
for f in ./assets/infrastructure/config/governance/*; do
    # Governance configs have a bunch of '$'' in them, so we can't use envsubst
    # envsubst < ${f} > ${LOCAL_DIR}/config/governance/$(basename ${f})
    cp ${f} ${LOCAL_DIR}/config/governance/$(basename ${f})
done

# Generic
for f in ./assets/infrastructure/config/pipeline/*; do
    envsubst < ${f} > ${LOCAL_DIR}/config/pipeline/$(basename ${f})
done

kubectl create configmap utility-config \
    --from-file ${LOCAL_DIR}/config/utility \
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

kubectl create configmap utility-bin-config \
    --from-file ${LOCAL_DIR}/config/bin \
    -n "${NAMESPACE}" \
    --save-config \
    --dry-run=client \
    -oyaml > ${LOCAL_DIR}/utility-bin-config.yaml

kubectl -n "${NAMESPACE}" apply -f ${LOCAL_DIR}/utility-bin-config.yaml

export MANIFEST_DIR=./assets/infrastructure/manifests/utility/${MODE}

deploy_manifests ${MANIFEST_DIR}
