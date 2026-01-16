# Azure Static Web Hosting App version 1.3.2

A modular Terraform project deploying a globally distributed static website using Azure Storage for origin hosting and Azure Front Door (CDN) for edge acceleration, security, and SSL.

## Repository Structure

```
.
├── README.md               # Project documentation and setup instructions.
├── app/                    # Frontend assets (HTML/JS/CSS) to be hosted.
│   └── index.html          # The entry point for your static website.
├── main.tf                 # Root orchestrator; calls and connects the modules.
├── modules/                # Reusable building blocks for your infrastructure.
│   ├── cdn/                # Logic for Azure Front Door and global delivery.
│   │   ├── main.tf         # CDN resource definitions (Profiles, Endpoints).
│   │   ├── variables.tf    # Input "sockets" for the CDN module.
│   │   └── versions.tf     # Provider and Terraform version constraints.
│   └── storage/            # Logic for Azure Storage and Static Web hosting.
│       ├── main.tf         # Storage Account and Container definitions.
│       ├── output.tf       # Values (like URLs) exported to other modules.
│       ├── variables.tf    # Input "sockets" for the Storage module.
│       └── versions.tf     # Provider and Terraform version constraints.
├── provider.tf             # Azure provider settings and backend configuration.
├── terraform.tfvars        # Actual values for variables (Secrets/Env settings).
└── variables.tf            # Global variable declarations for the root level.
```

## Quick Start Guide
terraform init – Initializes the backend and downloads required modules/providers.

terraform plan – Previews the infrastructure changes and validates your configuration.

terraform apply – Provisions the Azure resources and outputs your site URL.

Verify – Open the Front Door endpoint in your browser to see your live site.

## Changelog
Version 1.3.2:
    - added 3rd graph to monitoring dashboard
Version 1.3.1:
    - added monitoring dashboard
Version 1.3.0:
    - added monitoring
Version 1.2.1:
    - changed health probe from http to https to resolve problem with origin host switch.
Version 1.2.0:
    - added error handling for 404 and 5xx error pages
