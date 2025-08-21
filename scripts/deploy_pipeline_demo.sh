#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

./scripts/add/50_pipeline_infra.sh
./scripts/add/51_pipeline_config.sh

set +x

clear
kubectl -n "${NAMESPACE}" get pod
echo ""
echo "Demo is ready!"
echo "Access Confluent Control Center at 'https://confluent.${BASE_DOMAIN}'"
echo "Access the Kibana dashboard at https://kibana.${BASE_DOMAIN}"
echo 'Exec into utility pod with `./shell.sh`'