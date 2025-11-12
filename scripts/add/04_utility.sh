#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

# Mode-specific configmaps; general utility configs
create_configmap_from_dir_with_envsubst \
    ./assets/infrastructure/config/utility/${MODE} \
    config/utility \
    utility-config

# Governance configs have a bunch of '$' in them, so we can't use envsubst
create_configmap_from_dir_without_envsubst \
    ./assets/infrastructure/config/governance \
    config/governance \
    utility-governance-config

# Pipeline configs
create_configmap_from_dir_with_envsubst \
    ./assets/infrastructure/config/pipeline \
    config/pipeline \
    utility-pipeline-config

# Mode-specific utility scripts; this gets mounted with defaultMode: 0755
create_configmap_from_dir_without_envsubst \
    ./assets/infrastructure/config/bin/${MODE} \
    config/bin \
    utility-bin-config

# Used to deploy the governance demo applications from the utility container
# No mode specific manifests; these do have environment substitutions
create_configmap_from_dir_with_envsubst \
    ./assets/demos/governance/application/manifests \
    governance/application/manifests \
    governance-application-manifests

export MANIFEST_DIR=./assets/infrastructure/manifests/utility/${MODE}

deploy_manifests ${MANIFEST_DIR}
