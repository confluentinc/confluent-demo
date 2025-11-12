#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

# Governance applications configs have a bunch of '$' in them, so we can't use envsubst
create_configmap_from_dir_with_envsubst \
    ./assets/demos/governance/application/config/${MODE} \
    governance/application/config \
    governance-application-config


# # No substitution needed here
# kubectl create configmap governance-applications-config \
#     --from-file ./assets/demos/governance/config/${MODE} \
#     -n "${NAMESPACE}" \
#     --save-config \
#     --dry-run=client \
#     -oyaml > ${LOCAL_DIR}/governance-config.yaml

# kubectl -n "${NAMESPACE}" apply -f ${LOCAL_DIR}/governance-config.yaml

# mkdir -p ${LOCAL_DIR}/governance-applications
# rm ${LOCAL_DIR}/governance-applications/* || true

# # These have environment substitutions
# for f in ./assets/demos/governance/applications/*; do
#     envsubst < ${f} > ${LOCAL_DIR}/governance-applications/$(basename ${f})
#     kubectl -n "${NAMESPACE}" apply -f ${LOCAL_DIR}/governance-applications/$(basename ${f})
# done
