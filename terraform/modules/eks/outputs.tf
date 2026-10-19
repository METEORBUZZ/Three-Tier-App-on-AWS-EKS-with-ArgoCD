# ==============================================================================
# EKS MODULE: OUTPUTS (RESULTS)
# ==============================================================================
# Important information about the created Kubernetes cluster that is displayed
# on your screen or saved for deployment tools (like Jenkins or kubectl).
# ==============================================================================

# 1. Cluster Unique Identifier
output "cluster_id" {
  description = "The unique identifier ID of the EKS cluster"
  value       = aws_eks_cluster.main.id
}

# 2. Cluster Human Name
output "cluster_name" {
  description = "The human-readable name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

# 3. Cluster Amazon Resource Name (ARN)
# Full official AWS address for security permissions
output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = aws_eks_cluster.main.arn
}

# 4. Cluster API Server Web Address
# The web URL that tools like 'kubectl' call to communicate with the cluster.
output "cluster_endpoint" {
  description = "The web address URL for the Kubernetes API server"
  value       = aws_eks_cluster.main.endpoint
}

# 5. Cluster Security Certificate
# The cryptographic digital certificate proving our connection is trusted.
# Marked as sensitive so Terraform won't print raw security keys in terminal logs.
output "cluster_certificate_authority_data" {
  description = "Digital security certificate data for authenticating with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

# 6. Worker Node Fleet ARN
output "node_group_arn" {
  description = "The Amazon Resource Name (ARN) of the worker server fleet"
  value       = aws_eks_node_group.main.arn
}

# 7. Worker Node Fleet Health Status
# Shows 'ACTIVE' when all worker computers are healthy and ready to run containers.
output "node_group_status" {
  description = "Current operational status of the worker computers (e.g. ACTIVE)"
  value       = aws_eks_node_group.main.status
}
