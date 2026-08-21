#!/bin/bash

export BASE_PUBLIC_IP=${1:-127.0.0.1}

# Super simple validation
if [[ "$BASE_PUBLIC_IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "Using IP ${BASE_PUBLIC_IP}"
    export BASE_PUBLIC_DOMAIN="$(echo ${BASE_PUBLIC_IP} | tr '.' '-').nip.io"
    export BASE_PUBLIC_HTTPS_DOMAIN="int.${BASE_PUBLIC_DOMAIN}"
    export BASE_PUBLIC_TLS_DOMAIN="ext.${BASE_PUBLIC_DOMAIN}"
    echo "Setting BASE_PUBLIC_DOMAIN in ./.env to ${BASE_PUBLIC_DOMAIN}"
    sed -i.bak "s|^export BASE_PUBLIC_DOMAIN=.*$|export BASE_PUBLIC_DOMAIN=${BASE_PUBLIC_DOMAIN}|g" ./.env
    sed -i.bak "s|^export BASE_PUBLIC_HTTPS_DOMAIN=.*$|export BASE_PUBLIC_HTTPS_DOMAIN=${BASE_PUBLIC_HTTPS_DOMAIN}|g" ./.env
    sed -i.bak "s|^export BASE_PUBLIC_TLS_DOMAIN=.*$|export BASE_PUBLIC_TLS_DOMAIN=${BASE_PUBLIC_TLS_DOMAIN}|g" ./.env
else
    echo "${BASE_PUBLIC_IP} is not a valid IP"
    exit 1
fi
