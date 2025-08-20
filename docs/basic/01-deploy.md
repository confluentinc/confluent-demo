# Basic Mode

## Install prerequisites

Provision a local Kubernetes cluster. Some options for this include:

* Docker Desktop (with built-in Kubernetes)
* Orbstack

In addition to access to a Kubernetes cluster, your workstation needs the following tools installed ([brew](https://brew.sh/) is a common way to install these on macOS):

* kubectl (configured with a Kubernetes context to access a Kubernetes cluster)
* keytool (comes with most Java runtimes)
* helm
* openssl
* cfssl
* jq

Additionally, you need access to github.com (i.e. github.com must not be blocked)

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

#### CLI Login

Exec into the confluent-utility-0 container:

```bash
./tools/shell.sh
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
