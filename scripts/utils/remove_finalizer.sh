#!/bin/bash

set -euo pipefail
# set -x

# Usage (either will work):
# ./scripts/utils/remove_finalizer.sh confluent-demo connector shoe-products
# ./scripts/utils/remove_finalizer.sh confluent-demo connector/shoe-products

. ./.env
. ./scripts/functions.sh

remove_finalizer $@
