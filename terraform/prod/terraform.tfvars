# ==============================================================================
# PROD ENVIRONMENT: VARIABLE VALUES (THE ACTUAL SETTINGS)
# ==============================================================================

# AWS Region
aws_region = "us-east-1"

# Stage tag
environment = "prod"

# Cluster name
cluster_name = "todo-prod-eks-cluster"

# Kubernetes version
kubernetes_version = "1.29"

# Network IP range for prod (10.30.x.x)
vpc_cidr = "10.30.0.0/16"

# Multi-AZ redundancy: 2 NAT Gateways so an AWS data center failure won't cause an outage
single_nat_gateway = false

# Virtual machine hardware size (t3.large: 2 vCPU, 8GB RAM for high capacity)
node_instance_types = ["t3.large"]

# Start with 3 servers, allow scaling between 2 and 5 servers
desired_node_count = 3
min_node_count     = 2
max_node_count     = 5
