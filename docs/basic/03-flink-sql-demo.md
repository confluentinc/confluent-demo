## Demo Flink SQL (in Basic Mode)

After doing the initial deployment (instructions in [Basic Setup](./01-deploy.md)), you can run the CP Flink SQL demo

Everything should be run from the utility pod, which has direct access to CFK and CMF from within the cluster.

You can exec into the pod with this:

```bash
kubectl -n confluent-demo exec -it confluent-utility-0 -- bash
```

(or use the helper script to get into the utility pod):

```bash
./tools/shell.sh
```

The `confluent` CLI uses these environment variables by default (these are set automatically):

```bash
CONFLUENT_CMF_CERTIFICATE_AUTHORITY_PATH=/root/certs/ca.crt
CONFLUENT_CMF_URL=http://cmf.confluent-demo.svc.cluster.local
```

Also, there are number of pre-seeded config files in `./config/` (`/root/config/`)
* `client.properties` - Used for connectivity to Kafka (and Schema Registry)
* `secret-kafka.json` - CMF Secret, used to configure clients to communciate with Kafka
* `secret-schemaregistry.json` - CMF Secret, used to configure clients to communciate with Schema Registry
* `esm-kafka.json` - CMF Environment Secret Mapping, associates kafka secret with a given CMF Environment
* `esm-schemaregistry.json` - CMF Environment Secret Mapping, associates SR secret with a given CMF Environment
* `pool-with-secrets.json` - CMF Compute Pool (information )
* `catalog.json` - CMF Catalog (contains information about Kafka cluster and SR cluster to be used by Flink SQL

# Kafka connectivity test

*Run from within the utility pod*

```bash
kafka-broker-api-versions --bootstrap-server kafka.confluent-demo.svc.cluster.local:9071 --command-config config/client.properties
```

Also, most `kafka-X` commands, such as `kafka-topics`, `kafka-console-producer`, and `kafka-console-consumer` should all work.

# Flink environment setup

*Run from within the utility pod*

```bash
confluent flink environment list

# Create secrets
curl \
  -H 'content-type: application/json' \
  -X POST \
  ${CONFLUENT_CMF_URL}/cmf/api/v1/secrets \
  -d@config/secret-kafka.json

curl \
  -H 'content-type: application/json' \
  -X POST \
  ${CONFLUENT_CMF_URL}/cmf/api/v1/secrets \
  -d@config/secret-schemaregistry.json

# Get secrets
curl ${CONFLUENT_CMF_URL}/cmf/api/v1/secrets | jq '.'

# Create secret mappings
curl \
  -H 'content-type: application/json' \
  -X POST \
  ${CONFLUENT_CMF_URL}/cmf/api/v1/environments/${CMF_ENVIRONMENT_NAME}/secret-mappings \
  -d@config/esm-kafka.json

curl \
  -H 'content-type: application/json' \
  -X POST \
  ${CONFLUENT_CMF_URL}/cmf/api/v1/environments/${CMF_ENVIRONMENT_NAME}/secret-mappings \
  -d@config/esm-schemaregistry.json

# Get secretmappings
curl ${CONFLUENT_CMF_URL}/cmf/api/v1/environments/${CMF_ENVIRONMENT_NAME}/secret-mappings | jq '.'

# Create catalog
confluent flink catalog create config/catalog.json

# List catalog(s)
confluent flink catalog list

# Create compute pool
confluent flink --environment ${CMF_ENVIRONMENT_NAME} compute-pool create config/pool-with-secrets.json

# List compute pool(s)
confluent flink --environment ${CMF_ENVIRONMENT_NAME} compute-pool list
```

Verify everything is wired up properly with a basic `SHOW TABLES` query.

*Run from within the utility pod*

```bash
# Run basic 'show tables' command (I think this runs directly from CMF)
confluent --environment ${CMF_ENVIRONMENT_NAME} flink statement create ddl1 \
  --catalog demo --database kafka --compute-pool pool --output json \
  --sql "SHOW TABLES;"
```

# Flink SQL

Start the Flink SQL Shell

*Run from within the utility pod*

```bash
confluent --environment ${CMF_ENVIRONMENT_NAME} --compute-pool pool flink shell
```

Flink SQL queries

*Run from within the **Flink SQL Shell***

```sql
show catalogs;

show databases;

--- Use demo catalog and kafka database
use `demo`.`kafka`;

show tables;

--- Do a select (note that when you run this, it has to pull a Docker image and start several containers, so this may take some time)
SELECT * FROM `demo`.`kafka`.`shoe-customers`;
```

*While the select is starting, also look at running containers from another terminal*

```bash
kubectl -n confluent-demo get pods
```

... Do other things?

Couple of queries to try (I think these all work)

```sql
SELECT
 `window_end`,
 COUNT(DISTINCT order_id) AS `num_orders`
FROM TABLE(
   TUMBLE(TABLE `shoe-orders`, DESCRIPTOR(`$rowtime`), INTERVAL '1' MINUTES))
GROUP BY `window_start`, `window_end`;

SELECT
 `window_start`, `window_end`,
 COUNT(DISTINCT order_id) AS `num_orders`
FROM TABLE(
   HOP(TABLE `shoe-orders`, DESCRIPTOR(`$rowtime`), INTERVAL '5' MINUTES, INTERVAL '10' MINUTES))
GROUP BY `window_start`, `window_end`;

SELECT 
  `order_id`,
  `shoe-orders`.`$rowtime`,
  `first_name`,
  `last_name` 
FROM `shoe-orders`
  INNER JOIN `shoe-customers`
  ON `shoe-orders`.`customer_id` = `shoe-customers`.`id`;
```