## Flink SQL Demo (in Basic Mode)

After doing the initial deployment (instructions in [Basic Setup](./01-deploy.md)), you can run the Flink SQL demo

This automates most of the setup process; you start with access to the Flink SQL CLI

Everything should be run from the utility pod, which has direct access to CFK and CMF from within the cluster.

You can exec into the pod with this:

```bash
kubectl -n confluent-demo exec -it confluent-utility-0 -- bash
```

(or use the helper script to get into the utility pod):

```bash
./shell.sh
```

Create the various CP Flink resources (script exists at `/root/bin/deploy_flink_infra` if you would like to examine it)

```bash
deploy_flink_sql_infra
```

The `confluent` CLI uses these environment variables by default (these are set automatically in the utility pod):


```bash
CONFLUENT_CMF_CERTIFICATE_AUTHORITY_PATH=/root/certs/ca.crt
CONFLUENT_CMF_URL=http://cmf.confluent-demo.svc.cluster.local
```

You can verify everything is set up correctly with these commands:

*Run from within the utility pod*

Log into MDS (will require that you copy a link into a browser to log in). Log in with the username `admin` and password `admin` (and click "Yes")

```bash
confluent login --url https://kafka:8090 --certificate-authority-path certs/ca.crt  --no-browser
```

```bash
# List Flink catalog(s)
confluent flink catalog list

# List Flink compute pool(s)
confluent flink --environment ${CMF_ENVIRONMENT_NAME} compute-pool list
```

Verify everything is wired up properly with a basic `SHOW TABLES` query.

# This does not currently work, due to a bug in CMF.

*Run from within the utility pod*

```bash
confluent --environment ${CMF_ENVIRONMENT_NAME} flink statement create ddl1 \
  --catalog demo --database kafka --compute-pool pool --output json \
  --sql "SHOW TABLES;"
```

(Optional) Remove the statement

```bash
confluent --environment ${CMF_ENVIRONMENT_NAME} flink statement delete --force ddl1
```

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

Try other Flink SQL queries, subject to the limitations of the Confluent Platform for Apache Flink SQL capabilities.

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
