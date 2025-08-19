# confluent-demo

Migrated from [justinrlee/confluent-demo](github.com/justinrlee/confluent-demo)

## Architecture

This runs a small Confluent Platform cluster on Kubernetes, intended for use on a local workstation (Docker Desktop Kubernetes or Orbstack)

There is currently one version of this demo: 'basic' mode, which has TLS but no authentication or authorization.

The installation script will install the following:

* Ingress NGINX Controller
* Keycloak pod
* Confluent for Kubernetes (CFK)
* CFK CRs:
    * 1x KRaft
    * 3x Kafka
    * 1x Schema Registry
    * 1x Connect
    * 1x Control Center (2.x i.e. "Next Gen")
* Flink Kubernetes Operator (FKO)
* Confluent Manager for Apache Flink (CMF)
* CMF CRs:
    * 1x FlinkEnvironment
    * 1x FlinkApplication

## Start Here

* [Basic Mode Installation](./docs/basic/01-deploy.md)
* [Basic Mode CSFLE Demo](./docs/basic/02-csfle.md)
* [Basic Mode Governance Demo](./docs/basic/02-governance.md)
* [Basic Mode CP Flink SQL Demo](./docs/basic/03-flink-sql-demo.md)