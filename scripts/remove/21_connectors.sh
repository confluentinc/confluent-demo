#!/bin/bash

set -e
# set -x

. ./.env
. ./scripts/functions.sh

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    Connector/shoe-customers \
    Connector/shoe-products \
    Connector/shoe-orders
