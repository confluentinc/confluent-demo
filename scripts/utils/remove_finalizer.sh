
#!/bin/bash

set -e
# set -x

. ./.env
. ./scripts/functions.sh

kubectl -n "${NAMESPACE}" patch -p '{"metadata":{"finalizers":null}}' -v8 --type=merge $1 $2 $3