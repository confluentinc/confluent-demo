# confluent-demo

Migrated from [justinrlee/confluent-demo](github.com/justinrlee/confluent-demo)

## Architecture

This runs a small Confluent Platform cluster on Kubernetes, intended for use on a local workstation (Docker Desktop Kubernetes or Orbstack)

There are two configurations of this demo:

1. 'basic' mode (functionally complete) - has TLS but no authN or authZ
1. 'oidc' mode (work in progress) - uses OIDC/OAuth2.0 (Keycloak) for authentication, is maybe 40% functionally complete

## Architecture

This repo will install the following:

* Ingress NGINX Controller (should probably be replaced with Gateway API)
* Keycloak pod (in oidc mode)
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

Go to one of these two docs to install everything

Basic Mode
* [Basic Mode Installation](./docs/basic/01-deploy.md)
* [Basic Mode CSFLE Demo](./docs/basic/02-csfle.md)
* [Basic Mode Governance Demo](./docs/basic/02-governance.md)
* [Basic Mode CP Flink SQL Demo](./docs/basic/03-flink-sql-demo.md)

OIDC Mode - WIP
* [OIDC Mode Installation](./docs/oidc/01-deploy.md)
