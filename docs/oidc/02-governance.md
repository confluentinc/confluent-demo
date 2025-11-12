## Data Governance Demo (Basic Mode)

After doing the initial deployment (instructions in [Basic Setup](./01-deploy.md)), you can run the Data Governance demo

From the repo root directory, install the governance add-on resources:

```bash
```


Everything should be run from the utility pod, which has direct access to CFK and CMF from within the cluster.

You can exec into the pod with this:

```bash
kubectl -n confluent-demo exec -it confluent-utility-0 -- bash
```

(or use the helper script to get into the utility pod):

```bash
./shell.sh
```

*Run from within the utility pod*

```
create_governance_topics
```

Verify the "csfle" Vault key was properly created (and auth works, etc.)

```bash
vault kv list transit/keys
```

Look at various rules and schemas in the `~/governance` directory (in the utility container)

Combine schema and rules into data governance "raw.orders" and "raw.recipes" rules:

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
    -H "Authorization: Bearer $(generate_token)" \
    -X POST \
    -H 'content-type:application/json' \
    ${SR}/subjects/raw.orders-value/versions \
    -d @raw.orders-value.v1.json | jq '.'

# Register the recipes schema
curl \
    -k \
    -H "Authorization: Bearer $(generate_token)" \
    -X POST \
    -H 'content-type:application/json' \
    ${SR}/subjects/raw.recipes-value/versions \
    -d @raw.recipes-value.v1.json | jq '.'
```


Once all the rules are in place, deploy the initial applications (run from utility container)

_(Run in the utility container)_
```bash
kubectl apply -f /root/governance/applications/recipe-producer-Job-v1.yaml
kubectl apply -f /root/governance/applications/recipe-consumer-Deployment-v1.yaml
kubectl apply -f /root/governance/applications/order-producer-Deployment.yaml
kubectl apply -f /root/governance/applications/order-consumer-Deployment.yaml
```

Also, deploy an application that creates an invalid recipe (not enough ingredients), and observe it landing in the recipe DLQ.

_(Run in the utility container)_
```bash
kubectl apply -f /root/governance/applications/recipe-producer-Job-v1-invalid.yaml
```

To demonstrate migration rules, register a compatibility group for the `raw.recipes-value` subject.

```bash
# Run in the utility container
curl \
    -k \
    -H "Authorization: Bearer $(generate_token)" \
    -X PUT \
    -H 'content-type:application/json' \
    ${SR}/config/raw.recipes-value \
    -d @governance/compatibility-config.json | jq '.'
```

Register recipes v2:

```bash
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
    | tee raw.recipes-value.v2.json | jq '.'

# Register the schema
curl \
    -k \
    -H "Authorization: Bearer $(generate_token)" \
    -X POST \
    -H 'content-type:application/json' \
    ${SR}/subjects/raw.recipes-value/versions \
    -d @raw.recipes-value.v2.json | jq '.'
```

And deploy v2 of the recipe application (note that it runs in parallel with v2 of the recipe application, even though it has a different schema)

```bash
# Run in the utility container
kubectl apply -f /root/governance/applications/recipe-producer-Job-v2.yaml
kubectl apply -f /root/governance/applications/recipe-consumer-Deployment-v2.yaml
```

Architecture:
* orders (continuous): order producer > raw.orders > order consumer
    * one version:
        * domain rules:
            * Data Transformation Rule: Transform recipe name (dashes and prefix)
            * CSFLE: "PII"
* recipes (one-shot) one-shot: recipe producer > raw.recipes > recipe consumer
    * v1:
        * domain rules:
            * Data Quality Rule: Ingredient count (DLQ > raw.recipes.dlq)
            * CSFLE: 'sensitive'
            * Data Transformation Rule: Transform recipe name (dashes and prefix)
    * v2:
        * migration rules:
            * upgrade: split chef name
            * downgrade: combine chef name
        * domain rules:
            * Data Quality Rule: Ingredient count (DLQ > raw.recipes.dlq)
            * CSFLE: 'sensitive'
            * Data Transformation Rule: Transform recipe name (dashes and prefix)

Demo walkthrough:
* Set up v1 of all schemas
* Deploy initial deploys
* Demo CSFLE (orders: PII)
* Demo DQ rule (recipes: ingredient count)
    * Produce one invalid recipe, see in DQ
* Demo DT rule (recipes: recipe ID)
* Set up migration rule?
    * Register config
    * Register new rule
* Demo data migration
