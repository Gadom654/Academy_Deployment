resource "kubernetes_secret" "acr_credentials" {
  metadata {
    name      = "acr-credentials"
    namespace = "flux-system"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${data.azurerm_container_registry.acr.login_server}" = {
          "username" = data.azurerm_container_registry.acr.admin_username
          "password" = data.azurerm_container_registry.acr.admin_password
          "email"    = "ci@paymentapp.com"
          "auth"     = base64encode("${data.azurerm_container_registry.acr.admin_username}:${data.azurerm_container_registry.acr.admin_password}")
        }
      }
    })
  }
}