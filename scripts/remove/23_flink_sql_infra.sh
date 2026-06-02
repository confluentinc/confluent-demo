#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

# Check if utility pod exists
if kubectl -n "${NAMESPACE}" get pod confluent-utility-0 > /dev/null 2>&1; then
    echo "Removing Flink SQL infrastructure via CMF API..."
    kubectl -n "${NAMESPACE}" exec confluent-utility-0 -- bash -c 'remove_flink_sql_infra' || true
else
    echo "Utility pod not found, skipping Flink SQL infrastructure removal"
fi
