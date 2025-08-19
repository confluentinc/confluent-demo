
#!/bin/bash

set -e
# set -x

. ./.env
. ./functions.sh

kubectl -n ${NAMESPACE} rollout restart statefulset kraft
kubectl -n ${NAMESPACE} rollout restart statefulset kafka
kubectl -n ${NAMESPACE} rollout restart statefulset schemaregistry
kubectl -n ${NAMESPACE} rollout restart statefulset connect
kubectl -n ${NAMESPACE} rollout restart statefulset controlcenter