#!/bin/bash

set -euo pipefail
# set -x

. ./.env
. ./scripts/functions.sh

# if [[ ${MODE} == "oidc" ]]; then
#     echo "Skipping CMF children deletion in OIDC mode"
#     exit 0
# fi

# if [[ $(kubectl get namespace | grep "${NAMESPACE}" | wc -l) -lt 1 ]]; then
#     echo "Namespace ${NAMESPACE} does not exist, skipping CMF children deletion"
#     exit 0
# fi

if [[ $(kubectl -n ${NAMESPACE} get pods -l app=confluent-utility | grep "1/1" | grep "Running" | wc -l) -lt 1 ]]; then
    echo "Confluent utility pod is not running, skipping CMF children deletion"
    exit 0
fi

# echo "This script has been replaced by `remove_flink_sql_infra`, which can be run from the utility pod"
echo "Running `remove_flink_sql_infra` in utility pod..."
kubectl -n "${NAMESPACE}" exec -it confluent-utility-0 -- bash -c '
    remove_flink_sql_infra
'
