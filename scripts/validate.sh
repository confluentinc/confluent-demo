#!/bin/bash

set -euo pipefail
# set -x

. ./.env
. ./scripts/functions.sh

MODE=$(cat ./local/mode)

# Note: escape nested single quotes with '\''
if [[ ${MODE} == "basic" ]]; then
    echo "Creating CSFLE Schema File"

    kubectl -n "${NAMESPACE}" exec -it confluent-utility-0 -- bash -c '
        jq -s '\''{
            schema: (.[0] | tojson),
            schemaType: "AVRO",
            ruleSet: {
                domainRules: [.[1]]
            }
        }'\'' governance/csfle-schema.json governance/csfle-encryptionRule.json | tee csfle.json
    '

    kubectl -n "${NAMESPACE}" exec -it confluent-utility-0 -- bash -c '
        curl -sk ${SR}/subjects/csfle-value/versions/latest | jq -r '\''.id'\''
    '

    echo "CSFLE Schema ID: ${CSFLE_SCHEMA_ID}"
    
    exit 0
fi
