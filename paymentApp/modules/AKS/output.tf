output "k8s_cluster_id" {
  value = azurerm_kubernetes_cluster.k8s.id
}
output "k8s_cluster_identity" {
  value = azurerm_kubernetes_cluster.k8s.identity[0].principal_id
}