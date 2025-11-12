#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

check_for_readiness
