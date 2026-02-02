# AWS ECSApp v0.2.0

This repository contains a simple Flask application that is deployed to AWS ECS using Terraform.

## Repository Structure
.
├── README.md # This README file
├── app # Flask application source code and Dockerfile
├── terraform # Terraform configuration files

## Quick Start Guide
terraform init – Initializes the backend and downloads required modules/providers.

terraform plan – Previews the infrastructure changes and validates your configuration.

terraform apply – Provisions the Azure resources and outputs your site URL.
## Changelog
Version 0.2.0:
    - terraform structure created
Version 0.1.0:
    - docker image creation directory