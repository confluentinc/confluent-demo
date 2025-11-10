#!/bin/bash

set -euo pipefail
# set -x

# Usage (either will work):
# ./scripts/utils/remove_finalizer.sh confluent-demo connector shoe-products
# ./scripts/utils/remove_finalizer.sh confluent-demo connector/shoe-products

. ./.env
. ./scripts/functions.sh

RESOURCE_TYPE=${1}
NS=${2:-${NAMESPACE}}

kubectl -n "${NS}" get ${RESOURCE_TYPE} -oname | while read -r RESOURCE; do
    echo "Removing finalizers for ${RESOURCE}"
    remove_finalizer "${NS}" "${RESOURCE}"
done
