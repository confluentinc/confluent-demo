#!/bin/bash

set -euo pipefail
set -x

INPUT_MODE=${1:-}

. ./.env
. ./scripts/functions.sh

mkdir -p ${LOCAL_DIR}

if [[ "${INPUT_MODE}" == "basic" || -z "${INPUT_MODE}" ]]; then
    echo 'Running in "basic" mode'
    export INSTALL_MODE=0
    echo 'basic' > ./local/mode
elif [[ "${INPUT_MODE}" == "oidc" ]]; then
    echo 'Running in "oidc" mode'
    export INSTALL_MODE=1
    echo 'oidc' > ./local/mode
elif [[ "${INPUT_MODE}" == "plaintext" ]]; then
    echo 'Running in "plaintext" mode'
    export INSTALL_MODE=2
    echo 'plaintext' > ./local/mode
else
    echo "Invalid mode provided: ${INPUT_MODE}"
    echo "Valid options are 'basic', 'oidc', or 'plaintext'"
    exit 1
fi

./scripts/add/01_nginx.sh
./scripts/add/02_vault.sh
./scripts/add/03_cfk.sh

./scripts/add/04_utility.sh

./scripts/add/05_keycloak.sh
./scripts/add/06_fko.sh

./scripts/add/10_cp_certs.sh

if [[ $INSTALL_MODE == 1 ]]; then
    echo 'Installing "oidc" CP Creds'
    ./scripts/add/10_cp_oidc_creds.sh
fi

./scripts/add/11_cp.sh

./scripts/add/12_cmf.sh

./scripts/add/20_topics.sh

# For now, don't install connectors in oidc mode
if [[ $INSTALL_MODE -ne 1 ]]; then
    ./scripts/add/21_connectors.sh
fi

./scripts/add/22_flink_resources.sh

./scripts/add/30_demo_infra.sh

./scripts/add/99_check_for_readiness.sh
