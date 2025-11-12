All are run from utility container

```bash
echo "alias k='kubectl'" >> /root/.bash_aliases
alias k='kubectl'
```


# CSFLE

```bash
echo "Verifying existence of vault key"

vault kv list transit/keys

echo "Creating csfle topic"
# Create a topic

kafka-topics --bootstrap-server "${BS}" --command-config config/client.properties --create --topic csfle --replication-factor=3

echo "Creating and registering csfle schema"

jq -s '{
    schema: (.[0] | tojson),
    schemaType: "AVRO",
    ruleSet: {
        domainRules: [.[1]]
    }
}' governance/csfle-schema.json governance/csfle-encryptionRule.json | tee csfle.json | jq '.'

# Register the schema
curl \
    -k \
    -X POST \
    -H 'content-type:application/json' \
    ${SR}/subjects/csfle-value/versions \
    -d @csfle.json | jq '.'

echo "Retreiving CSFLE schema ID"
# curl -k ${SR}/subjects/csfle-value/versions/latest

export CSFLE_SCHEMA_ID=$(curl -sk ${SR}/subjects/csfle-value/versions/latest | jq '.id')

echo "Using schema ID ${CSFLE_SCHEMA_ID} for CSFLE producer"

echo "Producing sample message"

echo '{"id": "userid1", "name": "firstname lastname", "birthday": "01/01/2020"}' | kafka-avro-console-producer \
    --bootstrap-server "${BS}" \
    --producer.config config/client.properties \
    --reader-config config/client.properties \
    --property schema.registry.url=${SR} \
    --property value.schema.id=${CSFLE_SCHEMA_ID} \
    --topic csfle

echo "Consuming raw message"

kafka-console-consumer \
    --bootstrap-server "${BS}" \
    --consumer.config config/client.properties \
    --topic csfle \
    --from-beginning \
    --max-messages=1

echo "Consuming decrypted message"

kafka-avro-console-consumer \
    --bootstrap-server "${BS}" \
    --consumer.config config/client.properties \
    --property schema.registry.url=${SR} \
    --formatter-config config/client.properties \
    --topic csfle \
    --from-beginning \
    --max-messages=1
```

# Governance

```bash
echo "Creating governance topics"

create_governance_topics

echo "Creating and registering schemas"

jq -s '{
    schema: (.[0] | tojson),
    metadata: .[1],
    schemaType: "AVRO",
    ruleSet: {
        domainRules: [
            .[2],
            .[3]
        ]
    }
}' \
    governance/schema-raw.order-value.avsc \
    governance/metadata-v1.json \
    governance/domain-rule-order-recipe-id.json \
    governance/domain-rule-encrypt-pii.json \
    | tee raw.orders-value.v1.json | jq '.'

jq -s '{
    schema: (.[0] | tojson),
    metadata: .[1],
    schemaType: "AVRO",
    ruleSet: {
        domainRules: [
            .[2],
            .[3],
            .[4]
        ]
    }
}' \
    governance/schema-raw.recipe-value-v1.avsc \
    governance/metadata-v1.json \
    governance/domain-rule-recipe-id.json \
    governance/domain-rule-ingredients.json \
    governance/domain-rule-encrypt-sensitive.json \
    | tee raw.recipes-value.v1.json | jq '.'

# Register the orders schema
curl \
    -k \
    -X POST \
    -H 'content-type:application/json' \
    ${SR}/subjects/raw.orders-value/versions \
    -d @raw.orders-value.v1.json | jq '.'

# Register the recipes schema
curl \
    -k \
    -X POST \
    -H 'content-type:application/json' \
    ${SR}/subjects/raw.recipes-value/versions \
    -d @raw.recipes-value.v1.json | jq '.'

echo "Deploying applications"

kubectl apply -f /root/governance/applications/recipe-producer-Job-v1.yaml
kubectl apply -f /root/governance/applications/recipe-consumer-Deployment-v1.yaml
kubectl apply -f /root/governance/applications/order-producer-Deployment.yaml
kubectl apply -f /root/governance/applications/order-consumer-Deployment.yaml

echo "Deploying application with invalid data"

kubectl apply -f /root/governance/applications/recipe-producer-Job-v1-invalid.yaml

echo "Reading recipe from raw.recipes topic"

kafka-console-consumer \
    --bootstrap-server "${BS}" \
    --consumer.config config/client.properties \
    --topic raw.recipes \
    --from-beginning \
    --max-messages=1

echo "Reading recipe from raw.recipes.dlq topic"

kafka-console-consumer \
    --bootstrap-server "${BS}" \
    --consumer.config config/client.properties \
    --topic raw.recipes.dlq \
    --from-beginning \
    --max-messages=1

echo "Setting compatibility mode for raw.recipes topic"

curl \
    -k \
    -X PUT \
    -H 'content-type:application/json' \
    ${SR}/config/raw.recipes-value \
    -d @governance/compatibility-config.json | jq '.'

echo "Creating and registering migration rule schema"

jq -s '{
    schema: (.[0] | tojson),
    metadata: .[1],
    schemaType: "AVRO",
    ruleSet: {
        domainRules: [
            .[2],
            .[3],
            .[4]
        ],
        migrationRules: [
            .[5],
            .[6]
        ]
    }
}' \
    governance/schema-raw.recipe-value-v2.avsc \
    governance/metadata-v2.json \
    governance/domain-rule-recipe-id.json \
    governance/domain-rule-ingredients.json \
    governance/domain-rule-encrypt-sensitive.json \
    governance/migration-rule-downgrade.json \
    governance/migration-rule-upgrade.json \
    | tee raw.recipes-value.v2.json | jq '.'

# Register the schema
curl \
    -k \
    -X POST \
    -H 'content-type:application/json' \
    ${SR}/subjects/raw.recipes-value/versions \
    -d @raw.recipes-value.v2.json | jq '.'

echo "Deploying v2 recipe applications"

kubectl apply -f /root/governance/applications/recipe-producer-Job-v2.yaml
kubectl apply -f /root/governance/applications/recipe-consumer-Deployment-v2.yaml

echo "Consuming both recipes"

kafka-console-consumer \
    --bootstrap-server "${BS}" \
    --consumer.config config/client.properties \
    --topic raw.recipes \
    --from-beginning \
    --max-messages=2
```

# Flink SQL

```bash
deploy_flink_sql_infra

# List Flink catalog(s)
confluent flink catalog list

# List Flink compute pool(s)
confluent flink --environment ${CMF_ENVIRONMENT_NAME} compute-pool list

confluent --environment ${CMF_ENVIRONMENT_NAME} flink statement create ddl1 \
  --catalog demo --database kafka --compute-pool pool --output json \
  --sql "SHOW TABLES;"

confluent --environment ${CMF_ENVIRONMENT_NAME} flink statement delete --force ddl1
```

Verify everything is wired up properly with a basic `SHOW TABLES` query.

*Run from within the utility pod*

```bash
confluent --environment ${CMF_ENVIRONMENT_NAME} --compute-pool pool flink shell
```

```sql
SELECT * FROM `demo`.`kafka`.`shoe-customers`;
```
