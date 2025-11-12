#!/bin/bash

set -euo pipefail
# set -x

# Reverse order of install.sh
# Governance demo is a special case because it is created manually, so it is not in the install script
./scripts/remove/50_pipeline_demo.sh
./scripts/remove/40_governance_infra.sh

./scripts/remove/35_cmf_children.sh
./scripts/remove/22_flink_resources.sh
./scripts/remove/21_connectors.sh
./scripts/remove/20_topics.sh
./scripts/remove/12_cmf.sh

# Removal scripts are declarative and idempotent; it is safe to run both oidc and basic mode deletion
./scripts/remove/11_cp_basic.sh
./scripts/remove/11_cp_oidc.sh

./scripts/remove/10_cp_certs.sh
./scripts/remove/05_keycloak.sh
./scripts/remove/04_utility.sh
./scripts/remove/03_cfk.sh
./scripts/remove/02_vault.sh
./scripts/remove/01_nginx.sh
