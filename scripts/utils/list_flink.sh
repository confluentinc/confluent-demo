#!/bin/bash

set -euo pipefail

. ./.env
. ./scripts/functions.sh

echo "Listing Flink Environments in ${FLINK_DEV_NAMESPACE}..."
kubectl -n ${FLINK_DEV_NAMESPACE} get FlinkEnvironment,FlinkApplication,FlinkDeployment,Pod

echo "--------"

echo "Listing Flink Environments in ${FLINK_PROD_NAMESPACE}..."
kubectl -n ${FLINK_PROD_NAMESPACE} get FlinkEnvironment,FlinkApplication,FlinkDeployment,Pod
