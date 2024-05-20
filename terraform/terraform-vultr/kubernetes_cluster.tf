resource "vultr_kubernetes" "tf_kubernetes_cluster" {
    region = "blr"
    label     = "tf-cluster"
    version = "v1.28.9+1"

    node_pools {
        node_quantity = 3
        plan = "vc2-2c-4gb"
        label = "tf-k8s-nodes"
        auto_scaler = true
        min_nodes = 1
        max_nodes = 4
    }
}
