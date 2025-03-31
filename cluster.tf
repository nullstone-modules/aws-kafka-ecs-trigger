data "ns_app_connection" "cluster_namespace" {
  name     = "cluster-namespace"
  contract = "cluster-namespace/aws/ecs:*"
}

locals {
  app_cluster_arn = data.ns_app_connection.cluster_namespace.outputs.cluster_arn
}
