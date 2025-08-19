#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

###### Creates / Installs the following:

### Secrets:
# tls-kraft
# tls-kafka
# tls-connect
# tls-controlcenter
# tls-schemaregistry
# tls-client
# mds-token

# Create certificates
# export CERT_DIR=./local/certs
# export CFSSL_DIR=./local/cfssl
mkdir -p ${CERT_DIR} ${CFSSL_DIR}

# Copy CA certificates
copy_ca_certs

create_certificate_secret kraft
create_certificate_secret kafka
create_certificate_secret connect
create_certificate_secret controlcenter
create_certificate_secret schemaregistry
create_certificate_secret client

remove_if_deleted secret mds-token

kubectl create secret generic mds-token \
  --from-file=mdsPublicKey.pem=assets/mds/mds.pub \
  --from-file=mdsTokenKeyPair.pem=assets/mds/mds.key \
  --namespace ${NAMESPACE} \
    --save-config \
    --dry-run=client \
    -oyaml | kubectl apply -f -

wait_for_pod app=confluent-operator
