

# CSFLE

```bash
# Get key
vault kv list transit/keys

#####
# Create Schema
jq -s '{
    schema: (.[0] | tojson),
    schemaType: "AVRO",
    ruleSet: {
        domainRules: [.[1]]
    }
}' governance/csfle-schema.json governance/csfle-encryptionRule.json | tee csfle.json

# Create topic
kafka-topics --bootstrap-server "${BS}" --command-config config/client.properties --create --topic csfle --replication-factor=3

# Register the schema
curl \
    -k \
    -X POST \
    -H 'content-type:application/json' \
    ${SR}/subjects/csfle-value/versions \
    -d @csfle.json

######
# See the schema (might be 6, depending on what else you've done)
curl -k ${SR}/subjects/csfle-value/versions/latest

# Get schema
export CSFLE_SCHEMA_ID=$(curl -k ${SR}/subjects/csfle-value/versions/latest | jq '.id')

echo ${CSFLE_SCHEMA_ID}

# Produce message
echo '{"id": "userid1", "name": "firstname lastname", "birthday": "01/01/2020"}' | \
kafka-avro-console-producer \
    --bootstrap-server "${BS}" \
    --producer.config config/client.properties \
    --reader-config config/client.properties \
    --property schema.registry.url=${SR} \
    --property value.schema.id=${CSFLE_SCHEMA_ID} \
    --topic csfle

# Read message
kafka-console-consumer \
    --bootstrap-server "${BS}" \
    --consumer.config config/client.properties \
    --topic csfle \
    --from-beginning \
    --max-messages=1
```

# Governance

```bash
# Run in the project directory
./scripts/deploy_governance_demo.sh
```


```bash
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
    | tee raw.orders-value.v1.json

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
    | tee raw.recipes-value.v1.json

# Register the orders schema
curl \
    -k \
    -X POST \
    -H 'content-type:application/json' \
    ${SR}/subjects/raw.orders-value/versions \
    -d @raw.orders-value.v1.json

# Register the recipes schema
curl \
    -k \
    -X POST \
    -H 'content-type:application/json' \
    ${SR}/subjects/raw.recipes-value/versions \
    -d @raw.recipes-value.v1.json
```

```bash
./scripts/add/42_governance_deploy_v1_apps.sh
./scripts/add/43_governance_invalid_recipe.sh
```

```bash
# Run in the utility container
curl \
    -k \
    -X PUT \
    -H 'content-type:application/json' \
    ${SR}/config/raw.recipes-value \
    -d @governance/compatibility-config.json

# Run in the utility container
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
    | tee raw.recipes-value.v2.json

# Register the schema
curl \
    -k \
    -X POST \
    -H 'content-type:application/json' \
    ${SR}/subjects/raw.recipes-value/versions \
    -d @raw.recipes-value.v2.json
```


```bash
# Run in the project directory
./scripts/add/44_governance_deploy_v2_apps.sh
```

# Flink SQL


```bash
./scripts/deploy_flink_sql_infra.sh
```

```bash
confluent flink --environment ${CMF_ENVIRONMENT_NAME} compute-pool list

confluent --environment ${CMF_ENVIRONMENT_NAME} flink statement create ddl1 \
  --catalog demo --database kafka --compute-pool pool --output json \
  --sql "SHOW TABLES;"


confluent --environment ${CMF_ENVIRONMENT_NAME} flink statement delete --force ddl1


confluent --environment ${CMF_ENVIRONMENT_NAME} --compute-pool pool flink shell
```

```sql
show catalogs;

show databases;

--- Use demo catalog and kafka database
use `demo`.`kafka`;

show tables;

--- Do a select (note that when you run this, it has to pull a Docker image and start several containers, so this may take some time)
SELECT * FROM `demo`.`kafka`.`shoe-customers`;
```

# Namespace
kubectl patch -p '{"metadata":{"finalizers":null}}' --type=merge -v=8 namespace ingress-nginx