#!/bin/bash

set -e
# set -x

. ./.env
. ./scripts/functions.sh

# Statements are environment-scoped
echo "Getting and deleting Flink SQL Statements"
kubectl -n ${NAMESPACE} exec -it confluent-utility-0 -- \
    sh -c \
        'confluent flink --environment ${CMF_ENVIRONMENT_NAME} statement list -ojson \
            | jq -r ".[].metadata.name" \
            | while read STATEMENT;
                do
                echo "Deleting Flink SQL Statement ${STATEMENT}";
                confluent flink --environment ${CMF_ENVIRONMENT_NAME} statement delete --force ${STATEMENT};
            done'

echo "Getting and deleting Flink SQL Catalogs"
# Catalogs are not environment-scoped
kubectl -n ${NAMESPACE} exec -it confluent-utility-0 -- \
    sh -c \
        'confluent flink catalog list -ojson \
            | jq -r ".[].metadata.name" \
            | while read CATALOG;
                do
                echo "Deleting Flink Catalog ${CATALOG}";
                confluent flink catalog delete --force ${CATALOG};
            done'

echo "Getting and deleting Flink Secret Mappings"
# Delete all secret mappings
kubectl -n ${NAMESPACE} exec -it confluent-utility-0 -- \
    sh -c \
        'curl ${CONFLUENT_CMF_URL}/cmf/api/v1/environments/${CMF_ENVIRONMENT_NAME}/secret-mappings \
            | jq -r ".items[].metadata.name" \
            | while read SECRET_MAPPING;
                do
                echo "Deleting Secret Mapping ${SECRET_MAPPING}";
                curl -X DELETE "${CONFLUENT_CMF_URL}/cmf/api/v1/environments/${CMF_ENVIRONMENT_NAME}/secret-mappings/${SECRET_MAPPING}";
            done'

echo "Getting and deleting Flink Secrets"
# Delete all secrets
kubectl -n ${NAMESPACE} exec -it confluent-utility-0 -- \
    sh -c \
        'curl ${CONFLUENT_CMF_URL}/cmf/api/v1/secrets \
            | jq -r ".items[].metadata.name" \
            | while read SECRET;
                do
                echo "Deleting Secret ${SECRET}";
                curl -X DELETE "${CONFLUENT_CMF_URL}/cmf/api/v1/secrets/${SECRET}";
            done'

echo "Getting and deleting Flink Compute Pools"
# Compute pools are environment-scoped
kubectl -n ${NAMESPACE} exec -it confluent-utility-0 -- \
    sh -c \
        'confluent flink --environment ${CMF_ENVIRONMENT_NAME} compute-pool list -ojson \
            | jq -r ".[].metadata.name" \
            | while read COMPUTE_POOL;
                do
                echo "Deleting Flink Compute Pool ${COMPUTE_POOL}";
                confluent flink --environment ${CMF_ENVIRONMENT_NAME} compute-pool delete --force ${COMPUTE_POOL};
            done'
