#!/bin/bash

set -eo pipefail
# No set -u because we want to allow empty variables
# set -u
# set -x

. ./.env
. ./scripts/functions.sh

kubectl -n "${NAMESPACE}" patch -p '{"metadata":{"finalizers":null}}' -v8 --type=merge $1 $2 $3