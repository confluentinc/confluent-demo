#!/bin/bash

set -e
# set -x

. ./.env
. ./functions.sh

kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    KafkaTopic/shoe-customers \
    KafkaTopic/shoe-products \
    KafkaTopic/shoe-orders
