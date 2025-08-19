#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

export MANIFEST_DIR=./assets/manifests/vault

# Install Vault repo
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# Create namespace if it doesn't exist
kubectl create namespace ${VAULT_NAMESPACE} --dry-run=client -oyaml | kubectl apply -f -

# Deploy Vault
# dev mode results in a root token of `root`, and is unsealed by default
# The unseal key shows up the vault pod logs
# TODO: Figure out if we need to save the unseal key (when does vault get automatically sealed?)
# export VAULT_ADDR=http://vault.vault.svc.cluster.local:8200
helm upgrade --install vault \
    hashicorp/vault \
    --namespace ${VAULT_NAMESPACE} \
    --set "server.dev.enabled=true" \
    --version ${VAULT_CHART_VERSION}

wait_for_pod app.kubernetes.io/name=vault 1 ${VAULT_NAMESPACE}

# Includes the following resources:
# Ingress/vault
deploy_manifests ${MANIFEST_DIR}

kubectl -n ${VAULT_NAMESPACE} exec -it vault-0 -- sh -c "vault secrets enable transit" || true
kubectl -n ${VAULT_NAMESPACE} exec -it vault-0 -- sh -c "vault write -f transit/keys/csfle" || true
