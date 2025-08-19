#!/bin/bash

set -e
# set -x

. ./.env
. ./functions.sh

RESOURCES=$(kubectl api-resources --namespaced=true -oname --verbs=get | grep -v event)

for R in ${RESOURCES[@]};
do 
# echo ${R}
kubectl get ${R} -n ${NAMESPACE} -oname
done

echo "--------"

echo "This doesn't currently delete anything, just list all items in the namespace"

echo "To remove the finalizer for a resource, run this:"
echo "kubectl -n ${NAMESPACE} patch -p '{\"metadata\":{\"finalizers\":null}}' -v8 --type=merge  <resourcename>/<resourcetype>"

# echo "for example"

# echo "kubectl -n confluent-demo patch -p '{\"metadata\":{\"finalizers\":null}}' -v8 --type=merge flinkapplication.platform.confluent.io/state-machine-example"
# echo "kubectl -n confluent-demo patch -p '{\"metadata\":{\"finalizers\":null}}' -v8 --type=merge flinkenvironment/confluent-demo"
# echo "kubectl -n confluent-demo patch -p '{\"metadata\":{\"finalizers\":null}}' -v8 --type=merge flinkdeployment.flink.apache.org/state-machine-example"