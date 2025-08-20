#!/bin/bash

set -e
# set -x

. ./.env
. ./scripts/functions.sh

# Basic infra
kubectl -n ${NAMESPACE} delete \
    --ignore-not-found=true \
    secret \
        tls-kraft \
        tls-kafka \
        tls-connect \
        tls-controlcenter \
        tls-schemaregistry \
        tls-client \
        mds-token
