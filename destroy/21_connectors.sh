#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

kubectl -n ${NAMESPACE} delete \
    Connector/shoe-customers \
    Connector/shoe-products \
    Connector/shoe-orders
