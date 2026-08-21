## TODO (Repo-level)


* Bump utility container
* Refactor set_BASE_PUBLIC_DOMAIN into function

* Look at Kubernetes Gateway API
    * Revalidate keycloak (ext vs. int)
    * Revalidate vault (int)
    * Fix kafka (plaintext)
    * Verify client config files work
        * Plaintext
        * Basic
        * OIDC
* Look at jq or kustomize templating for basic vs. oidc
* Look at client config properties (.properties and .json files reflected into utility container), revalidate which ones support templating or not.

* Refactor: combine prereqs scripts
* Refactor: split out deploys from waits
* Switch CMF cleanup to API calls instead of CLI
* Improve Documentation
* Suppress error messages

* Determine whether to update CRDs on all Helm installations:
    * Gateway
    * CMF
    * FKO

* Determine if we need to save the vault unseal key (in scripts/add/02_vault.sh)

* Determine whether to use custom Helm repos

* Remove all FlinkApplication/FlinkEnvironments before removing FlinkDeployments (scripts/remove/22_flink_resources.sh)

* Determine whether to deploy ksqlDB in initial CP deployment

* ~~Data governance stuff~~
* ~~Refactor: move cfk secrets from infra to cfk~~
* ~~Move CP CSFLE manifests to container~~
* ~~Refactor: break cpf into FKO and CMF~~
* ~~Refactor to single:~~
    * ~~vault~~
    * ~~connectors~~
    * ~~topics~~
    * ~~utility~~
* ~~Refactor: combine install/uninstall scripts~~
* ~~Refactor: split flinkapp/flinkenv into separate script~~
* ~~Refactor certificate generation into function~~
* ~~Move versions.sh > .env~~
* ~~rearrange installation / uninstallation scripts to use functions~~
* ~~Size CPU / Memory~~
* ~~Cleanup scripts~~
* ~~change startup detection~~
* ~~figure out how to remove cert-manager~~
* ~~Update to 8.0.0 (CP and CPF/CMF)~~
* ~~support orbstack~~
* ~~verify we remove cfk helm chart~~

## TODO Basic

* Add real Flink job
* ... other demo things?
* ~~do the rest of data governance~~
* ~~support remote installation~~

## TODO (OIDC Infra)

* Support custom base domain
* Fix OIDC for KafkaRestClass for KafkaTopics
* Get OIDC working for CMF
* Use distinct credentials for each service
* add FlinkEnvironment/FlinkApplication authentication/authorization
* ~~rename 'cmf-rbac' to 'cmf-oidc'~~
* Support remote installation

## TODO Demo
* Replace ksqlDB job with Flink job
* Flink compute pool, catalog, statements
* Add connectors (and plugins) - shoe store
* Add real Flink job
* ... other demo things?
