# OIDC Mode

## Check Prerequisites

This will prompt for the Kubernetes context to use, and optionally allow you to indicate the IP address used to access Kubernetes services exposed via the Ingress NGINX controller.

```bash
./check_prereqs.sh
```

## Installation

```bash
./install.sh oidc
```

Monitor pods as they come up (need Control Center to have 3/3 running containers); this may take some time to start.

```bash
kubectl -n confluent-demo get pods -w
```

(You can also monitor C3 logs with `kubectl -n confluent-demo logs -f controlcenter-0 -c controlcenter`)

Open up the control center UI: https://confluent.127-0-0-1.nip.io/

Log in with `admin`/`admin`

... Poke around?

#### CLI Login

Exec into the confluent-utility-0 container:

```bash
kubectl -n confluent-demo exec -it confluent-utility-0 -- bash
```

Login:

```bash
confluent login --url https://kafka:8090 --certificate-authority-path certs/ca.crt  --no-browser
```

### Cleanup

```bash
./uninstall_oidc.sh
```
