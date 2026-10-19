# ==============================================================================
# DEV ENVIRONMENT: MAIN ORCHESTRATION BLUEPRINT
# ==============================================================================
# In simple terms:
# This file assembles our infrastructure like LEGO blocks by calling our two
# reusable modules:
#   1. module "vpc": Builds the Dev network (VPC, subnets, gateways).
#   2. module "eks": Builds the Dev Kubernetes cluster inside that network.
# ==============================================================================

# ------------------------------------------------------------------------------
# BLOCK 1: Build the Dev Network (VPC)
# ------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc" # Use the shared VPC blueprint

  environment        = var.environment
  cluster_name       = var.cluster_name
  vpc_cidr           = var.vpc_cidr
  single_nat_gateway = var.single_nat_gateway
}

# ------------------------------------------------------------------------------
# BLOCK 2: Build the Dev Kubernetes Cluster (EKS)
# ------------------------------------------------------------------------------
module "eks" {
  source = "../../modules/eks" # Use the shared EKS blueprint

  environment        = var.environment
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version

  # Place the management control plane across all subnets
  subnet_ids = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)

  # Place our worker computers safely inside the private subnets
  node_subnet_ids = module.vpc.private_subnet_ids

  # Scaling and hardware settings for Dev
  node_instance_types = var.node_instance_types
  desired_node_count  = var.desired_node_count
  min_node_count      = var.min_node_count
  max_node_count      = var.max_node_count
}
