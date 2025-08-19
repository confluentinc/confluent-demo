# Basic Mode

## Install prerequisites

Provision a local Kubernetes cluster. Some options for this include:

* Docker Desktop (with built-in Kubernetes)
* Orbstack

## Install prereqs

## Check Prerequisites

This will prompt for the Kubernetes context to use, and optionally allow you to indicate the IP address used to access Kubernetes services exposed via the Ingress NGINX controller.

```bash
./check_prereqs.sh
```

## Installation

```bash
./install.sh
```

Monitor pods as they come up (need Control Center to have 3/3 running containers); this may take some time to start.

```bash
kubectl -n confluent-demo get pods -w
```

(You can also monitor C3 logs with `kubectl -n confluent-demo logs -f controlcenter-0 -c controlcenter`)

Open up the control center UI: https://confluent.127-0-0-1.nip.io/

... Poke around?

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

* [Data Governance (CSFLE) Demo](./02-csfle.md)
* [CP Flink SQL Demo](./03-flink-sql-demo.md)
* [Cleanup](./99-cleanup.md)
