#!/bin/bash

set -euo pipefail
set -x

. ./.env
. ./scripts/functions.sh

./scripts/add/60_flink_sql_infra.sh
