# Basic Mode

## Install prerequisites

This demo runs entirely in a Kubernetes cluster. Some options for running this locally on a workstation include:

* Docker Desktop (with built-in Kubernetes) - see the [Docker Desktop Documentation](https://docs.docker.com/desktop/features/kubernetes/)
* Orbstack - see the [Orbstack Documentation](https://orbstack.dev/)

In addition to access to a Kubernetes cluster, your workstation several CLI tools installed. [Brew](https://brew.sh/) is a common way to install these on macOS.

Requirements:

* kubectl (configured with a Kubernetes context to access a Kubernetes cluster)
* keytool (comes with most Java runtimes)
* helm
* openssl
* cfssl
* jq

Additionally, you need access to github.com (i.e. https://github.com must not be blocked)

## Clone the git repo

In some directory on your workstation, clone the git repo, and then change into the directory:

```bash
git clone https://github.com/confluentinc/confluent-demo
cd confluent-demo
```

## Run pre-check

This will prompt for the Kubernetes context to use, and optionally allow you to indicate the IP address used to access Kubernetes services exposed via the Ingress NGINX controller.

It will also validate some of the prerequisites.

(If you're installing to a local Kubernetes cluster, e.g. Docker Desktop or OrbStack, you can use the default `127.0.0.1`)

```bash
./precheck.sh
```

## Installation

```bash
./install.sh
```

The installation script will monitor the deployment process.

(You can also monitor Control Center logs with `kubectl -n confluent-demo logs -f controlcenter-0 -c controlcenter`)

Open up the Control Center UI: https://confluent.127-0-0-1.nip.io/

... Poke around?

To add the cp-demo components:
* ksqlDB
* Elasticsearch
* Kibana
* Wikipedia > SSE > ksqlDB > Elastic pipeline

Run this:

```bash
./scripts/deploy_demo.sh
```

Open up the Kibana UI: https://kibana.127-0-0-1.nip.io/

#### CLI Login

Exec into the confluent-utility-0 container:

```bash
./shell.sh
```

(This is a wrapper on this command: `kubectl -n confluent-demo exec -it confluent-utility-0 -- bash`)


Confluent CLI should generally work for interacting with CP Flink:

```bash
confluent flink environment list
```

### Next Steps

* [CSFLE Demo](./02-csfle.md)
* [Data Governance Demo](./02-governance.md)
* [CP Flink SQL Demo](./03-flink-sql-demo.md)

### Cleanup

```bash
./uninstall.sh
```
