#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

./deploy/50_pipeline_infra.sh
./deploy/51_pipeline_config.sh