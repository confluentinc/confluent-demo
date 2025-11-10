#!/bin/bash

set -euo pipefail
# set -x

. ./.env
. ./scripts/functions.sh

for NS in ${FLINK_DEV_NAMESPACE} ${FLINK_PROD_NAMESPACE}; do

    if [[ $(kubectl get namespace | grep "${NS}" | wc -l) -lt 1 ]]; then
        echo "Namespace ${NS} does not exist, skipping Flink resource deletion"
        continue
    else
        export MANIFEST_DIR=./assets/resources/flink/${NS}
        echo "Removing Flink resources from namespace ${NS}..."
        delete_manifests ${MANIFEST_DIR}

        wait_for_flink_deployments_to_be_removed ${NS}
        sleep 2

        kubectl delete namespace "${NS}" --ignore-not-found=true
    fi
done
