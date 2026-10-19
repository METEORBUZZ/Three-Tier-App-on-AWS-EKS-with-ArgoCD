# ==============================================================================
# STAGE ENVIRONMENT: CLOUD PROVIDER CONFIGURATION
# ==============================================================================
# This file connects Terraform to AWS for the STAGE (Pre-Production) environment.
# STAGE mirrors production as closely as possible to test changes before live release.
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

  # Automatic tracking tags for Stage
  default_tags {
    tags = {
      Project     = "TodoApp"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
