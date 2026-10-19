# ==============================================================================
# STAGE: MAIN INFRASTRUCTURE
# ==============================================================================
# Sets up AWS Provider and builds Stage VPC and EKS Cluster using shared modules.
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # (Optional) Remote S3 Backend for teams:
  # backend "s3" {
  #   bucket         = "todo-terraform-state-bucket"
  #   key            = "todo-app/stage/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "TodoApp"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# ------------------------------------------------------------------------------
# 1. Stage Network (VPC)
# ------------------------------------------------------------------------------
module "vpc" {
  source = "../modules/vpc"

  environment        = var.environment
  cluster_name       = var.cluster_name
  vpc_cidr           = var.vpc_cidr
  single_nat_gateway = var.single_nat_gateway
}

# ------------------------------------------------------------------------------
# 2. Stage Kubernetes Cluster (EKS)
# ------------------------------------------------------------------------------
module "eks" {
  source = "../modules/eks"

  environment        = var.environment
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version

  subnet_ids      = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  node_subnet_ids = module.vpc.private_subnet_ids

  node_instance_types = var.node_instance_types
  desired_node_count  = var.desired_node_count
  min_node_count      = var.min_node_count
  max_node_count      = var.max_node_count
}
