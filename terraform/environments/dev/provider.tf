# ==============================================================================
# DEV ENVIRONMENT: CLOUD PROVIDER CONFIGURATION
# ==============================================================================
# This file tells Terraform:
#   1. Which tool to use: AWS Provider plugin.
#   2. Which AWS Region to build in: e.g. us-east-1 (N. Virginia).
#   3. What automatic labels (tags) to stick onto every single resource built.
# ==============================================================================

terraform {
  # We require Terraform version 1.5.0 or newer
  required_version = ">= 1.5.0"

  required_providers {
    # Download the official Amazon Web Services (AWS) connector plugin
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS connection
provider "aws" {
  region = var.aws_region # Geographic data center location (e.g. us-east-1)

  # Every resource created will automatically receive these labels for billing & tracking
  default_tags {
    tags = {
      Project     = "TodoApp"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
