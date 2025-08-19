#!/bin/bash

if [[ $1 == "oidc" ]]; then
    echo "Running in OIDC mode"
    export INSTALL_MODE=1
else
    echo "Running in basic mode"
    export INSTALL_MODE=0
fi

set -e
set -x

. ./.env
. ./functions.sh

./deploy/01_nginx.sh
./deploy/02_vault.sh
./deploy/03_cfk.sh
./deploy/04_utility.sh
./deploy/05_keycloak.sh
./deploy/06_fko.sh

./deploy/10_cp_certs.sh

if [[ $INSTALL_MODE == 1 ]]; then
    echo "Installing OIDC CP and CMF"
    ./deploy/11_cp_oidc.sh
    ./deploy/12_cmf_oidc.sh
else
    echo "Installing Basic CP and CMF"
    ./deploy/11_cp_basic.sh
    ./deploy/12_cmf_basic.sh
fi

./deploy/20_topics.sh
./deploy/21_connectors.sh
./deploy/22_flink_resources.sh

./deploy/99_check_for_readiness.sh