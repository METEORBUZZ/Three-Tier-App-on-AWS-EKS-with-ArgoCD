# ==============================================================================
# PROD ENVIRONMENT: OUTPUTS (FINAL RECEIPT & INSTRUCTIONS)
# ==============================================================================

# 1. Deployed stage name
output "environment" {
  description = "The deployed environment stage"
  value       = var.environment
}

# 2. Cluster Name
output "cluster_name" {
  description = "The name of the Production Kubernetes cluster"
  value       = module.eks.cluster_name
}

# 3. Cluster API URL
output "cluster_endpoint" {
  description = "The web address for the Production Kubernetes API"
  value       = module.eks.cluster_endpoint
}

# 4. Security Certificate (Hidden for safety)
output "cluster_certificate_authority_data" {
  description = "The security certificate for Production cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

# 5. Network ID
output "vpc_id" {
  description = "The AWS ID number of the Production network"
  value       = module.vpc.vpc_id
}

# 6. Public Subnets
output "public_subnets" {
  description = "List of public subnet IDs in Production"
  value       = module.vpc.public_subnet_ids
}

# 7. Private Subnets
output "private_subnets" {
  description = "List of private subnet IDs in Production"
  value       = module.vpc.private_subnet_ids
}

# 8. Copy-paste terminal command to connect kubectl to this Production cluster
output "update_kubeconfig_command" {
  description = "Copy and run this command in terminal to connect to the Production cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
