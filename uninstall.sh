#!/bin/bash


# Reverse order of install.sh
# Governance demo is a special case because it is created manually, so it is not in the install script
./destroy/40_governance_demo.sh

./destroy/30_cmf_children.sh
./destroy/22_flink_resources.sh
./destroy/21_connectors.sh
./destroy/20_topics.sh
./destroy/12_cmf.sh

# Removal scripts are declarative and idempotent; it is safe to run both oidc and basic mode deletion
./destroy/11_cp_basic.sh
./destroy/11_cp_oidc.sh

./destroy/10_cp_certs.sh
./destroy/05_keycloak.sh
./destroy/04_utility.sh
./destroy/03_cfk.sh
./destroy/02_vault.sh
./destroy/01_nginx.sh