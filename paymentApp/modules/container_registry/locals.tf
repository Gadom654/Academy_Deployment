locals {
  container_registry_name           = "${var.prefix}containerreg"
  container_registry_sku_standard   = "Basic"
  container_registry_admin_enabled  = true
  container_registry_admin_username = "adminuser"
  build_flask_image_task_name       = "BuildFlaskImageTask"
  platform_os                       = "Linux"
  dockerfile_path                   = "Dockerfile"
  context_path                      = "https://github.com/Gadom654/ContainerApp#main:app"
  access_token                      = var.github_access_token
  image_names                       = ["flask:v1.0.0"]
}