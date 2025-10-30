#!/bin/bash

if [[ $1 == "basic" || -z "${1}" ]]; then
    echo 'Running in "basic" mode'
    export INSTALL_MODE=0
    echo 'basic' > ./local/mode
elif [[ $1 == "oidc" ]]; then
    echo 'Running in "oidc" mode'
    export INSTALL_MODE=1
    echo 'oidc' > ./local/mode
elif [[ $1 == "plaintext" ]]; then
    echo 'Running in "plaintext" mode'
    export INSTALL_MODE=2
    echo 'plaintext' > ./local/mode
else
    echo "Invalid mode provided: ${1}"
    echo "Valid options are 'basic', 'oidc', or 'plaintext'"
    exit 1
fi

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

./scripts/add/01_nginx.sh
./scripts/add/02_vault.sh
./scripts/add/03_cfk.sh

if [[ $INSTALL_MODE == 1 ]]; then
    # TODO: Implement oidc mode utility
    echo 'Installing "oidc" mode utility'
    ./scripts/add/04_utility.sh
elif [[ $INSTALL_MODE == 2 ]]; then
    echo 'Installing "plaintext" mode utility'
    ./scripts/add/04_utility_plaintext.sh
else
    # TODO Refactor: rename to 04_utility_basic.sh
    echo 'Installing "basic" mode utility'
    ./scripts/add/04_utility.sh
fi

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
    ./scripts/add/12_cmf_plaintext.sh
else
    echo 'Installing "basic" CP and CMF'
    ./scripts/add/11_cp_basic.sh
    ./scripts/add/12_cmf_basic.sh
fi

./scripts/add/20_topics.sh
./scripts/add/21_connectors.sh
./scripts/add/22_flink_resources.sh

./scripts/add/99_check_for_readiness.sh