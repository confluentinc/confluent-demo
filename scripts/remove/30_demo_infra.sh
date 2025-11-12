#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

kubectl -n "${NAMESPACE}" delete \
    --ignore-not-found=true \
    ConfigMap/governance-application-config
