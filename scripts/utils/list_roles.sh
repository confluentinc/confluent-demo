#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

kubectl -n "${NAMESPACE}" get ConfluentRoleBinding -ojson   \
    | jq '[.items[] | {name: .metadata.name, spec: .spec}]' \
    | yq -P
