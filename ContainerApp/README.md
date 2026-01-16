# Azure Containers App v1.2.1

This repository contains a simple Flask application that is deployed to Azure Container Apps using Terraform.

## Repository Structure
.
├── .github # GitHub Actions workflows for CI/CD
├── README.md # This README file
├── app # Flask application source code and Dockerfile
│   ├── Dockerfile # Defines the Docker image for the Flask app
│   ├── app.py # The main Flask application file
│   └── requirements.txt # Python dependencies for the Flask app
├── locals.tf # Local variables for the root Terraform configuration
├── main.tf # Main Terraform configuration file
├── modules # Reusable Terraform modules for different infrastructure components
│   ├── app_gateway # Module for Azure Application Gateway
│   │   ├── locals.tf # Local variables for the app_gateway module
│   │   ├── main.tf # Main configuration for the app_gateway module
│   │   ├── output.tf # Outputs for the app_gateway module
│   │   ├── variables.tf # Input variables for the app_gateway module
│   │   └── versions.tf # Version constraints for providers used in app_gateway
│   ├── container_app # Module for Azure Container App
│   │   ├── locals.tf # Local variables for the container_app module
│   │   ├── main.tf # Main configuration for the container_app module
│   │   ├── output.tf # Outputs for the container_app module
│   │   ├── variables.tf # Input variables for the container_app module
│   │   └── versions.tf # Version constraints for providers used in container_app
│   ├── container_registry # Module for Azure Container Registry
│   │   ├── locals.tf # Local variables for the container_registry module
│   │   ├── main.tf # Main configuration for the container_registry module
│   │   ├── output.tf # Outputs for the container_registry module
│   │   ├── variables.tf # Input variables for the container_registry module
│   │   └── versions.tf # Version constraints for providers used in container_registry
│   ├── monitoring # Module for Azure Monitoring resources (e.g., Log Analytics)
│   │   ├── locals.tf # Local variables for the monitoring module
│   │   ├── main.tf # Main configuration for the monitoring module
│   │   ├── output.tf # Outputs for the monitoring module
│   │   ├── variables.tf # Input variables for the monitoring module
│   │   └── versions.tf # Version constraints for providers used in monitoring
│   └── network # Module for Azure Networking resources (e.g., VNet, Subnets)
│       ├── locals.tf # Local variables for the network module
│       ├── main.tf # Main configuration for the network module
│       ├── output.tf # Outputs for the network module
│       ├── variables.tf # Input variables for the network module
│       └── versions.tf # Version constraints for providers used in network
├── provider.tf # Terraform provider configuration
├── terraform.tfvars # Variable definitions for Terraform deployment
└── variables.tf # Input variables for the root Terraform configuration

## Quick Start Guide
terraform init – Initializes the backend and downloads required modules/providers.

terraform plan – Previews the infrastructure changes and validates your configuration.

terraform apply – Provisions the Azure resources and outputs your site URL.
## Changelog
Version 1.2.1:
    - added KEDA autoscaling based on CPU usage
Version 1.2.0:
    - added autoscaling based on CPU usage
Version 1.1.1:
    - fixed terraform artifact in CI/CD pipeline
Version 1.1:
    - added CI/CD pipeline
Version 1.0:
    - 1st working version of application deployed with terraform