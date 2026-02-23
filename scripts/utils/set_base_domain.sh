#!/bin/bash

export BASE_IP=${1:-127.0.0.1}

# Super simple validation
if [[ "$BASE_IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "Using IP ${BASE_IP}"
    export BASE_DOMAIN="$(echo ${BASE_IP} | tr '.' '-').nip.io"
    export BASE_INT_DOMAIN="int.${BASE_DOMAIN}"
    export BASE_EXT_DOMAIN="ext.${BASE_DOMAIN}"
    echo "Setting BASE_DOMAIN in ./.env to ${BASE_DOMAIN}"
    sed -i.bak "s|^export BASE_DOMAIN=.*$|export BASE_DOMAIN=${BASE_DOMAIN}|g" ./.env
    sed -i.bak "s|^export BASE_INT_DOMAIN=.*$|export BASE_INT_DOMAIN=${BASE_INT_DOMAIN}|g" ./.env
    sed -i.bak "s|^export BASE_EXT_DOMAIN=.*$|export BASE_EXT_DOMAIN=${BASE_EXT_DOMAIN}|g" ./.env
else
    echo "${BASE_IP} is not a valid IP"
    exit 1
fi
