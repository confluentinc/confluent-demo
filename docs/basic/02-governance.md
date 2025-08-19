## CSFLE Demo (Basic Mode)

**This is currently only a very simple CSFLE demo**

After doing the initial deployment (instructions in [Basic Setup](./01-deploy.md)), you can run the Data Governance demo (currently only includes CSFLE)

From the repo root directory, install the governance add-on resources:

```bash
./deploy/40_governance_infra.sh
```


Everything should be run from the utility pod, which has direct access to CFK and CMF from within the cluster.

You can exec into the pod with this:

```bash
kubectl -n confluent-demo exec -it confluent-utility-0 -- bash
```

(or use the helper script to get into the utility pod):

```bash
./tools/shell.sh
```

*Run from within the utility pod*

Verify the csfle Vault key was properly created (and auth works, etc.)

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


Once all the rules are in place, deploy the initial applications (from the project directory)

```bash
# Run in the project directory
./deploy/42_governance_deploy_v1_apps.sh
```

Deploy a job with an invalid recipe (not enough ingredients), and observe it landing in the recipe DLQ.

```bash
# Run in the project directory
./deploy/43_governance_invalid_recipe.sh
```

_(Run in the utility container)_

Register compatibility group:

```bash
# Run in the utility container
curl \
    -k \
    -X PUT \
    -H 'content-type:application/json' \
    ${SR}/config/raw.recipes-value \
    -d @governance/compatibility-config.json
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
    | tee raw.recipes-value.v2.json

# Register the schema
curl \
    -k \
    -X POST \
    -H 'content-type:application/json' \
    ${SR}/subjects/raw.recipes-value/versions \
    -d @raw.recipes-value.v2.json
```

Deploy v2 of recipe applications

```bash
# Run in the project directory
./deploy/44_governance_deploy_v2_apps.sh
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