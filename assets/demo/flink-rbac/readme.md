# remove confluent-demo cpf resources
kubectl -n confluent-demo delete \
    flinkapplication.platform.confluent.io/state-machine-example \
    flinkenvironment.platform.confluent.io/confluent-demo

# grant admin access to all FEs
kubectl -n confluent-demo apply -f assets/demo/flink-rbac/_global
kubectl -n confluent-demo apply -f assets/demo/flink-rbac/development
kubectl -n confluent-demo apply -f assets/demo/flink-rbac/production

# pre-cleanup
kubectl -n confluent-demo delete flinkapplication.platform.confluent.io/production-state-machine-example-bar
kubectl -n confluent-demo delete flinkapplication.platform.confluent.io/production-state-machine-example-foo
kubectl -n confluent-demo delete flinkenvironment.platform.confluent.io/production

kubectl -n confluent-demo delete flinkapplication.platform.confluent.io/development-state-machine-example
kubectl -n confluent-demo delete flinkenvironment.platform.confluent.io/development

kubectl -n confluent-demo delete -f assets/demo/flink-rbac/production
kubectl -n confluent-demo delete -f assets/demo/flink-rbac/development
kubectl -n confluent-demo delete -f assets/demo/flink-rbac/_global
