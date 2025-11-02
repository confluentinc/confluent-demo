#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

export MANIFEST_DIR=./assets/demos/governance/applications

deploy_single_manifest ${MANIFEST_DIR} recipe-producer-Job-v1-invalid.yaml
