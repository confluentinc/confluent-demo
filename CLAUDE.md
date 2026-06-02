# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository provides a complete Confluent Platform demo environment running on Kubernetes, designed for local workstation deployment (Docker Desktop Kubernetes or OrbStack). It includes Kafka, Schema Registry, Connect, Control Center, Flink, and supporting infrastructure.

## Installation Modes

The demo supports three installation modes:

- **basic**: TLS encryption without authentication/authorization (default, fully functional)
- **oidc**: TLS encryption with OIDC authentication (work in progress)
- **plaintext**: No TLS, no authentication (for testing)

Mode is specified when running `./install.sh [mode]` and persisted to `./local/mode`.

## Prerequisites

Required CLI tools (validated by `./precheck.sh`):
- kubectl (with valid Kubernetes context)
- keytool (from Java runtime)
- helm
- openssl
- cfssl
- jq

Kubernetes cluster requirements:
- Minimum 8 CPUs allocated
- Access to github.com

## Common Commands

### Initial Setup
```bash
# Validate prerequisites and select Kubernetes context
./precheck.sh

# Install the demo (defaults to basic mode)
./install.sh

# Install with specific mode
./install.sh basic
./install.sh oidc
./install.sh plaintext
```

### Uninstall
```bash
# Remove all deployed resources
./uninstall.sh
```

### Access
```bash
# Open shell in utility pod (preconfigured with Confluent CLI)
./shell.sh

# Control Center UI (adjust domain based on BASE_DOMAIN in .env)
# https://confluent.ext.127-0-0-1.nip.io/
```

### Monitoring
```bash
# Watch Control Center logs
kubectl -n confluent-demo logs -f controlcenter-0 -c controlcenter

# Check pod status
kubectl -n confluent-demo get pods

# List all resources in namespace
./scripts/utils/list_full_namespace.sh
```

### Utility Scripts
```bash
# Refresh cluster (restart pods if not ready)
./scripts/utils/refresh_cluster.sh

# List Flink resources
./scripts/utils/list_flink.sh

# Set custom base domain
./scripts/utils/set_base_domain.sh <IP>

# Remove finalizers from stuck resources
./scripts/utils/remove_finalizer.sh
./scripts/utils/erase_finalizers.sh
```

## Architecture

### Component Installation Order

The `install.sh` script orchestrates installation via numbered scripts in `scripts/add/`:

1. **01_envoy.sh** - Envoy Gateway API Controller (for ingress)
2. **02_vault.sh** - HashiCorp Vault (for secrets management)
3. **03_cfk.sh** - Confluent for Kubernetes (CFK) operator
4. **04_utility.sh** - Utility pod with preconfigured Confluent CLI
5. **05_keycloak.sh** - Keycloak (OIDC provider, for oidc mode)
6. **06_fko.sh** - Flink Kubernetes Operator (FKO)
7. **10_cp_certs.sh** - Generate TLS certificates using cfssl
8. **10_cp_oidc_creds.sh** - Configure OIDC credentials (oidc mode only)
9. **11_cp.sh** - Deploy Confluent Platform components (Kafka, SR, Connect, C3)
10. **12_cmf.sh** - Deploy Confluent Manager for Apache Flink (CMF)
11. **20_topics.sh** - Create demo topics
12. **21_connectors.sh** - Deploy demo connectors (not in oidc mode)
13. **22_flink_resources.sh** - Deploy Flink environments and applications
14. **30_demo_infra.sh** - Additional demo infrastructure
15. **99_check_for_readiness.sh** - Wait for all pods to be ready

Uninstallation (`uninstall.sh`) runs corresponding `scripts/remove/` scripts in reverse order.

### Confluent Platform Components

Deployed via CFK Custom Resources (CRs):
- **KRaftController** (kraft): 1 instance for cluster metadata
- **Kafka** (kafka): 3 brokers
- **SchemaRegistry** (schemaregistry): 1 instance
- **Connect** (connect): 1 instance
- **ControlCenter** (controlcenter): 1 instance (Next Gen/2.x)

### Flink Components

- **Flink Kubernetes Operator**: Manages Flink resources
- **Confluent Manager for Apache Flink (CMF)**: Flink management interface
- **FlinkEnvironments**: Isolated Flink execution contexts
  - Development: `confluent-demo-development` namespace
  - Production: `confluent-demo-production` namespace
- **FlinkApplications**: Flink SQL applications running in environments

### Networking

Uses Kubernetes Gateway API (Envoy Gateway) for ingress:
- TLSRoute resources expose services
- Three domain tiers defined in `.env`:
  - `BASE_DOMAIN`: Base domain (e.g., 127-0-0-1.nip.io)
  - `BASE_INT_DOMAIN`: Internal domain (int.127-0-0-1.nip.io)
  - `BASE_EXT_DOMAIN`: External domain (ext.127-0-0-1.nip.io)

## Directory Structure

### Configuration and Manifests
- `assets/infrastructure/manifests/` - Kubernetes manifests organized by component and mode
  - `cfk/{basic,oidc,plaintext}/` - Confluent Platform CRs
  - `cmf/{basic,oidc,plaintext}/` - CMF manifests (ServiceAccount, Roles, etc.)
  - `gateway/` - Gateway API resources
  - `keycloak/` - Keycloak deployment
  - `vault/` - Vault deployment
  - `utility/{basic,oidc,plaintext}/` - Utility pod manifests
- `assets/infrastructure/config/` - Configuration files (client props, etc.)
- `assets/infrastructure/helm-values/` - Helm values files for CMF
- `assets/infrastructure/security/` - Security-related configs (certs, encryption, MDS)

### Resources
- `assets/resources/topics/` - Topic definitions
- `assets/resources/connectors/` - Connector configurations
- `assets/resources/flink/` - Flink resource definitions
  - `confluent-demo-development/` - Development FlinkEnvironment/FlinkApplication
  - `confluent-demo-production/` - Production FlinkEnvironment/FlinkApplication (2 apps)

### Demos
- `assets/demos/governance/` - Data governance demo assets
- `assets/demos/pipeline/` - Data pipeline demo assets

### Local State
- `local/` - Generated during installation (gitignored)
  - `local/mode` - Current installation mode
  - `local/certs/` - Generated TLS certificates
  - `local/cfssl/` - CFSSL intermediate files
  - `local/config/` - Generated configuration files

### Documentation
- `docs/basic/` - Documentation for basic mode
  - `01-deploy.md` - Installation guide
  - `02-csfle.md` - Client-Side Field-Level Encryption demo
  - `02-governance.md` - Data governance demo
  - `03-flink-sql-demo.md` - Flink SQL demo
- `docs/oidc/` - Documentation for OIDC mode (WIP)

## Environment Configuration

All versions and configuration are defined in `.env`:

### Component Versions
- `CFK_CHART_VERSION` - Confluent for Kubernetes Helm chart (0.1514.40, app version 3.2.2)
- `CFK_INIT_CONTAINER_VERSION` - CFK init container version (3.2.2)
- `CMF_VERSION` - Confluent Manager for Apache Flink version (2.3.1)
- `FKO_VERSION` - Flink Kubernetes Operator version (1.140.1)
- `CONFLUENT_PLATFORM_VERSION` - Confluent Platform (Kafka) version (8.2.1)
- `CONFLUENT_PLATFORM_SR_VERSION` - Schema Registry version (7.9.6, intentionally older due to DEK Registry RBAC constraints)
- `CONTROL_CENTER_VERSION` - Control Center Next Gen version (2.5.0)
- `CP_FLINK_TAG` - Confluent Platform Flink image tag (2.1.2-cp1-java21)
- `CP_FLINK_SQL_TAG` - Confluent Platform Flink SQL tag (1.19-cp8)
- `ENVOY_GATEWAY_VERSION` - Envoy Gateway API controller version (v1.8.0)
- `VAULT_CHART_VERSION` - HashiCorp Vault Helm chart version (0.32.0)

### Namespaces
- `NAMESPACE=confluent-demo` - Main namespace for Confluent Platform
- `OPERATOR_NAMESPACE=confluent-demo` - Operator namespace
- `ENVOY_GATEWAY_NAMESPACE=envoy-gateway` - Gateway controller namespace
- `KEYCLOAK_NAMESPACE=keycloak` - Keycloak namespace
- `VAULT_NAMESPACE=vault` - Vault namespace

### Domain Configuration
Updated by `./precheck.sh` or `./scripts/utils/set_base_domain.sh`:
- `BASE_DOMAIN` - Base nip.io domain
- `BASE_INT_DOMAIN` - Internal subdomain
- `BASE_EXT_DOMAIN` - External subdomain

## Helper Functions

The `scripts/functions.sh` file provides utility functions sourced by installation scripts:

- `wait_for_pod <label> [count] [namespace]` - Wait for pods with label to be ready
- `wait_for_c3` - Wait for Control Center (3 containers)
- `wait_for_connector <name>` - Wait for connector to be RUNNING
- `remove_if_deleted <type> <name>` - Clean up resources stuck in deletion
- `restart_if_not_ready <pod>` - Restart pod if not ready
- `check_for_readiness` - Orchestrate waiting for all components

## Installation Script Patterns

All `scripts/add/*.sh` and `scripts/remove/*.sh` scripts follow this pattern:

```bash
#!/bin/bash
set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

# Script body
```

Installation scripts use `${MODE}` variable (from `./local/mode`) to select mode-specific manifests.

## Working with Manifests

Mode-specific manifests are organized as:
- `assets/infrastructure/manifests/{component}/{basic,oidc,plaintext}/`

When adding new resources:
1. Create mode-specific manifest files
2. Reference using `${MODE}` variable in deployment scripts
3. Add corresponding removal logic to `scripts/remove/` scripts

## Flink Resource Management

Flink resources are organized by namespace/environment:
- **Development**: Single FlinkApplication in `confluent-demo-development`
- **Production**: Two FlinkApplications in `confluent-demo-production`

Each has separate FlinkEnvironment and FlinkApplication YAML files in `assets/resources/flink/`.
