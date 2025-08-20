#!/bin/bash

. ./.env

kubectl -n ${NAMESPACE} exec -it confluent-utility-0 -- bash