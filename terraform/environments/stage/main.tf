# ==============================================================================
# STAGE ENVIRONMENT: MAIN ORCHESTRATION BLUEPRINT
# ==============================================================================
# In simple terms:
# Reuses the standard VPC and EKS blueprints with Stage settings.
# ==============================================================================

# ------------------------------------------------------------------------------
# BLOCK 1: Build the Stage Network (VPC)
# ------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  environment        = var.environment
  cluster_name       = var.cluster_name
  vpc_cidr           = var.vpc_cidr
  single_nat_gateway = var.single_nat_gateway
}

# ------------------------------------------------------------------------------
# BLOCK 2: Build the Stage Kubernetes Cluster (EKS)
# ------------------------------------------------------------------------------
module "eks" {
  source = "../../modules/eks"

  environment        = var.environment
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version

  # Place the management control plane across all subnets
  subnet_ids = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)

  # Place worker computers safely inside private subnets
  node_subnet_ids = module.vpc.private_subnet_ids

  # Scaling and hardware settings for Stage
  node_instance_types = var.node_instance_types
  desired_node_count  = var.desired_node_count
  min_node_count      = var.min_node_count
  max_node_count      = var.max_node_count
}
