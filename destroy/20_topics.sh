#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

kubectl -n ${NAMESPACE} delete \
    KafkaTopic/shoe-customers \
    KafkaTopic/shoe-products \
    KafkaTopic/shoe-orders
