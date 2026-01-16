# terraform_step_1.ps1

# (opcjonalnie, tylko raz)
terraform init -upgrade

# podejrzyj co poleci (debug)
Write-Host "Running: terraform apply $($targets -join ' ')"

# odpal apply tylko na powyższe zasoby
terraform apply -auto-approve