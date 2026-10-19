# ==============================================================================
# VPC MODULE: OUTPUTS (RESULTS)
# ==============================================================================
# Think of outputs as a receipt printed after building the network.
# These values (like network IDs) are passed along to the EKS module so it knows
# where to place our Kubernetes servers.
# ==============================================================================

# The unique ID number that AWS gave to our new network.
output "vpc_id" {
  description = "The unique ID of the created VPC"
  value       = aws_vpc.main.id
}

# The IP address range assigned to our network.
output "vpc_cidr_block" {
  description = "The IP address range of the VPC"
  value       = aws_vpc.main.cidr_block
}

# The list of ID numbers for the public subnets (where load balancers sit).
output "public_subnet_ids" {
  description = "List of IDs for the public subnets"
  value       = aws_subnet.public[*].id
}

# The list of ID numbers for the private subnets (where worker servers sit).
output "private_subnet_ids" {
  description = "List of IDs for the secure private subnets"
  value       = aws_subnet.private[*].id
}
