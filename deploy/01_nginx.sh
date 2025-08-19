#!/bin/bash

## INSTALL NGINX INGRESS

set -e
set -x

. ./.env
. ./functions.sh

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx --force-update
helm repo update

kubectl create namespace ${INGRESS_NGINX_NAMESPACE} --dry-run=client -oyaml | kubectl apply -f -

helm upgrade --install ingress-nginx \
    ingress-nginx/ingress-nginx \
    --namespace ${INGRESS_NGINX_NAMESPACE} \
    --set "controller.extraArgs.enable-ssl-passthrough=" \
    --version ${INGRESS_NGINX_VERSION}

wait_for_pod app.kubernetes.io/name=ingress-nginx 1 ${INGRESS_NGINX_NAMESPACE}
