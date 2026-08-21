#!/bin/bash

export BASE_EXTERNAL_IP=${1:-127.0.0.1}

# Super simple validation
if [[ "$BASE_EXTERNAL_IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "Using IP ${BASE_EXTERNAL_IP}"
    export BASE_EXTERNAL_DOMAIN="$(echo ${BASE_EXTERNAL_IP} | tr '.' '-').nip.io"
    export BASE_EXTERNAL_HTTPS_DOMAIN="int.${BASE_EXTERNAL_DOMAIN}"
    export BASE_EXTERNAL_TLS_DOMAIN="ext.${BASE_EXTERNAL_DOMAIN}"
    echo "Setting BASE_EXTERNAL_DOMAIN in ./.env to ${BASE_EXTERNAL_DOMAIN}"
    sed -i.bak "s|^export BASE_EXTERNAL_DOMAIN=.*$|export BASE_EXTERNAL_DOMAIN=${BASE_EXTERNAL_DOMAIN}|g" ./.env
    sed -i.bak "s|^export BASE_EXTERNAL_HTTPS_DOMAIN=.*$|export BASE_EXTERNAL_HTTPS_DOMAIN=${BASE_EXTERNAL_HTTPS_DOMAIN}|g" ./.env
    sed -i.bak "s|^export BASE_EXTERNAL_TLS_DOMAIN=.*$|export BASE_EXTERNAL_TLS_DOMAIN=${BASE_EXTERNAL_TLS_DOMAIN}|g" ./.env
else
    echo "${BASE_EXTERNAL_IP} is not a valid IP"
    exit 1
fi
