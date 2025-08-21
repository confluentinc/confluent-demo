#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

###### ./assets/demo/pipeline/connectors includes these objects
# * Connector-wikipedia-sse-source
# * Connector-elasticsearch-sink

# Deployment flow:
# 1. Deploy source connector
# 2. Deploy ES mappings
# 3. Create Kibana dashboard
# 4. Create ksqlDB pipelines (must be done after source data is present)
# 5. Deploy sink connector (must be done after ES mappings are created)

deploy_single_manifest ./assets/demo/pipeline/connectors Connector-wikipedia-sse-source.yaml

wait_for_connector wikipedia-sse-source

# Have to deploy ES mappings before the sink connector starts sending data

echo ""
echo "Deploying Elasticsearch mapping for wikipedia_count_gt"
kubectl -n "${NAMESPACE}" exec -it confluent-utility-0 -- bash -c '
    curl -X PUT -H "content-type:application/json" -d @/root/pipeline/mapping-count.json "http://elasticsearch:9200/_template/wikipedia_count_gt?pretty"
'

echo ""
echo "Deploying Elasticsearch mapping for wikipediabot"
kubectl -n "${NAMESPACE}" exec -it confluent-utility-0 -- bash -c '
    curl -X PUT -H "content-type:application/json" -d @/root/pipeline/mapping-bot.json "http://elasticsearch:9200/_template/wikipediabot?pretty"
'

echo ""
echo "Deploying Kibana dashboard"
kubectl -n "${NAMESPACE}" exec -it confluent-utility-0 -- bash -c '
    curl -X POST "http://kibana:5601/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf: true" -H "securitytenant: global" --form file=@/root/pipeline/kibana.ndjson
'

echo ""
echo ""
echo "Creating ksqlDB pipelines"
kubectl -n "${NAMESPACE}" exec -it confluent-utility-0 -- bash -c '
    ksql --config-file /root/tls.properties https://ksqldb:8088 -f /root/pipeline/ksqldb.sql
'

echo "Deploying sink connector"
deploy_single_manifest ./assets/demo/pipeline/connectors Connector-elasticsearch-sink.yaml

echo "Access the Kibana dashboard at https://kibana.${BASE_DOMAIN}"