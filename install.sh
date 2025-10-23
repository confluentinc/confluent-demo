#!/bin/bash

if [[ $1 == "oidc" ]]; then
    echo 'Running in "oidc" mode'
    export INSTALL_MODE=1
elif [[ $1 == "plaintext" ]]; then
    echo 'Running in "plaintext" mode'
    export INSTALL_MODE=2
else
    echo 'Running in "basic" mode'
    export INSTALL_MODE=0
fi

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

./scripts/add/01_nginx.sh
./scripts/add/02_vault.sh
./scripts/add/03_cfk.sh
./scripts/add/04_utility.sh
./scripts/add/05_keycloak.sh
./scripts/add/06_fko.sh

./scripts/add/10_cp_certs.sh

if [[ $INSTALL_MODE == 1 ]]; then
    echo 'Installing "oidc" CP and CMF'
    ./scripts/add/11_cp_oidc.sh
    ./scripts/add/12_cmf_oidc.sh
elif [[ $INSTALL_MODE == 2 ]]; then
    echo 'Installing "plaintext" CP and CMF'
    ./scripts/add/11_cp_plaintext.sh
    # ./scripts/add/12_cmf_plaintext.sh
else
    echo 'Installing "basic" CP and CMF'
    ./scripts/add/11_cp_basic.sh
    ./scripts/add/12_cmf_basic.sh
fi

./scripts/add/20_topics.sh
./scripts/add/21_connectors.sh
./scripts/add/22_flink_resources.sh

./scripts/add/99_check_for_readiness.sh