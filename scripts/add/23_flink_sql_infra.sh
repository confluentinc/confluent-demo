#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

# Wait for CMF pod to be ready
wait_for_pod app.kubernetes.io/name=confluent-manager-for-apache-flink 1 ${NAMESPACE}

# Wait for utility pod to be ready
wait_for_pod app=confluent-utility 1 ${NAMESPACE}

# Wait for CMF API to be responsive
echo "Waiting for CMF API to be ready..."
set +x
for i in {1..30}; do
    if kubectl -n "${NAMESPACE}" exec confluent-utility-0 -- \
        sh -c 'curl -s -f "${CONFLUENT_CMF_URL}/cmf/api/v1/environments"' > \
        /dev/null 2>&1
    then
        echo "CMF API is ready"
        break
    fi
    echo "Waiting for CMF API... (attempt $i/30)"
    sleep 5
done
set -x

# Execute deployment script in utility pod
echo "Deploying Flink SQL infrastructure via CMF API..."
kubectl -n "${NAMESPACE}" exec confluent-utility-0 -- bash -c 'deploy_flink_sql_infra'

echo "Flink SQL infrastructure deployed successfully"
