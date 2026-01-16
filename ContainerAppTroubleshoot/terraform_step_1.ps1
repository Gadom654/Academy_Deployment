# terraform_step_1.ps1

# (opcjonalnie, tylko raz)
terraform init -upgrade

# targets jako tablica argumentów (splatting = zero problemów z łamaniami linii)
$targets = @(
  "-target=azurerm_resource_group.rg",
  "-target=azurerm_container_registry.acr",
  "-target=azurerm_user_assigned_identity.uami",
  "-target=azurerm_role_assignment.acr_pull"
)

# podejrzyj co poleci (debug)
Write-Host "Running: terraform apply $($targets -join ' ')"

# odpal apply tylko na powyższe zasoby
terraform apply @targets -auto-approve