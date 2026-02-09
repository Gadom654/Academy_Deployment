# AWS payment app v.0.1.0

This repository that is deploying AWS EKS using Terraform.

## Repository Structure
.
├── README.md # This README file
├── infra # Terraform configuration files for infrastructure resources changed quite ofter
├── platform # Terraform configuration files for infrastructure almost never changed like vpc subnets idm roles
├── app # Folder containing the application code build in Docker containers
├── helm # Helm charts to run on k8s cluster
## Quick Start Guide
1st start with terraform init and apply on platform directory to build VPC subnets and idm roles
2nd run terraform init, plan and apply on infra directory to build compute resources (DB,EKS)
3rd build docker container images and push them to ECR
4th build helm chart and push it to ECR
5th install helm chart on EKS cluster
## Changelog
Version 0.1.0:
    - creating base template for app