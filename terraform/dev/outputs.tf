# ==============================================================================
# DEV ENVIRONMENT: OUTPUTS (FINAL RECEIPT & INSTRUCTIONS)
# ==============================================================================
# After running 'terraform apply', these helpful values are printed right on screen.
# ==============================================================================

# 1. Confirms the stage that was deployed
output "environment" {
  description = "The deployed environment stage"
  value       = var.environment
}

# 2. Cluster Name
output "cluster_name" {
  description = "The name of the Dev Kubernetes cluster"
  value       = module.eks.cluster_name
}

# 3. Cluster API URL
output "cluster_endpoint" {
  description = "The web address for the Dev Kubernetes API"
  value       = module.eks.cluster_endpoint
}

# 4. Digital Security Certificate (Hidden from screen for security)
output "cluster_certificate_authority_data" {
  description = "The security certificate used to verify connection to Dev cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

# 5. Network ID
output "vpc_id" {
  description = "The AWS ID number of the Dev network"
  value       = module.vpc.vpc_id
}

# 6. Public Subnet IDs (where load balancers live)
output "public_subnets" {
  description = "List of public subnet IDs in Dev"
  value       = module.vpc.public_subnet_ids
}

# 7. Private Subnet IDs (where worker servers live)
output "private_subnets" {
  description = "List of private subnet IDs in Dev"
  value       = module.vpc.private_subnet_ids
}

# 8. Copy-paste terminal command to connect kubectl to this Dev cluster
output "update_kubeconfig_command" {
  description = "Copy and run this exact command in your terminal to connect to the cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
