#!/bin/bash

set -euo pipefail
# set -x

. ./.env
. ./scripts/functions.sh

kubectl -n "${NAMESPACE}" rollout restart statefulset kraft
kubectl -n "${NAMESPACE}" rollout restart statefulset kafka
kubectl -n "${NAMESPACE}" rollout restart statefulset schemaregistry
kubectl -n "${NAMESPACE}" rollout restart statefulset connect
kubectl -n "${NAMESPACE}" rollout restart statefulset controlcenter