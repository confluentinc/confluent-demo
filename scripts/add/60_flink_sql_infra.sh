#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

# Deployment flow (Uses existing CMF Environment)
# 1. Create CMF Secrets for kafka and schemaregistry
# 2. Create CMF Secret Mappings associating kafka and schemaregistry secrets with CMF Environment
# 3. Create Flink Catalog
# 4. Create Flink Compute Pool

echo ""
echo "Creating CMF Secrets for kafka and schemaregistry"
kubectl -n "${NAMESPACE}" exec -it confluent-utility-0 -- bash -c '
    curl \
        -H "content-type: application/json" \
        -X POST \
        "${CONFLUENT_CMF_URL}/cmf/api/v1/secrets" \
        -d@/root/config/secret-kafka.json
'

kubectl -n "${NAMESPACE}" exec -it confluent-utility-0 -- bash -c '
    curl \
        -H "content-type: application/json" \
        -X POST \
        "${CONFLUENT_CMF_URL}/cmf/api/v1/secrets" \
        -d@/root/config/secret-schemaregistry.json
'

echo ""
echo "Creating CMF Secret Mappings associating kafka and schemaregistry secrets with CMF Environment"
kubectl -n "${NAMESPACE}" exec -it confluent-utility-0 -- bash -c '
    curl \
        -H "content-type: application/json" \
        -X POST \
        "${CONFLUENT_CMF_URL}/cmf/api/v1/environments/${CMF_ENVIRONMENT_NAME}/secret-mappings" \
        -d@/root/config/esm-kafka.json
'
kubectl -n "${NAMESPACE}" exec -it confluent-utility-0 -- bash -c '
    curl \
        -H "content-type: application/json" \
        -X POST \
        "${CONFLUENT_CMF_URL}/cmf/api/v1/environments/${CMF_ENVIRONMENT_NAME}/secret-mappings" \
        -d@/root/config/esm-schemaregistry.json
'

echo ""
echo "Creating Flink Catalog"
kubectl -n "${NAMESPACE}" exec -it confluent-utility-0 -- bash -c '
    confluent flink catalog create /root/config/catalog.json || true
'

echo ""
echo "Creating Flink Compute Pool"
kubectl -n "${NAMESPACE}" exec -it confluent-utility-0 -- bash -c '
    confluent flink --environment ${CMF_ENVIRONMENT_NAME} compute-pool create /root/config/pool-with-secrets.json || true
'
