#!/bin/bash

# set -e
# set -x

. ./.env
. ./functions.sh

# Basic infra
kubectl -n ${NAMESPACE} delete \
    secret \
        tls-kraft \
        tls-kafka \
        tls-connect \
        tls-controlcenter \
        tls-schemaregistry \
        tls-client \
        mds-token \
        || true
