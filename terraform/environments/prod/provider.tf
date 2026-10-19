# ==============================================================================
# PROD ENVIRONMENT: CLOUD PROVIDER CONFIGURATION
# ==============================================================================
# This file connects Terraform to AWS for the PRODUCTION environment.
# PROD serves real end-users and requires highest availability, security, and redundancy.
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Automatic tracking tags for Production
  default_tags {
    tags = {
      Project     = "TodoApp"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
