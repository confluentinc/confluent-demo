#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

./scripts/add/40_governance_infra.sh
