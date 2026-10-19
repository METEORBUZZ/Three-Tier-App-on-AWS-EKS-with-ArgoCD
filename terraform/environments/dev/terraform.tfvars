# ==============================================================================
# DEV ENVIRONMENT: VARIABLE VALUES (THE ACTUAL SETTINGS)
# ==============================================================================
# You can customize these values anytime before applying.
# ==============================================================================

# AWS Region where resources will be hosted
aws_region = "us-east-1"

# Stage tag
environment = "dev"

# Cluster name
cluster_name = "todo-dev-eks-cluster"

# Kubernetes version
kubernetes_version = "1.29"

# Network IP range for dev (10.10.x.x)
vpc_cidr = "10.10.0.0/16"

# Keep costs low in dev by using 1 NAT Gateway instead of 2
single_nat_gateway = true

# Virtual machine hardware size (t3.medium: 2 vCPU, 4GB RAM)
node_instance_types = ["t3.medium"]

# Start with 1 server, allow scaling between 1 and 2 servers
desired_node_count = 1
min_node_count     = 1
max_node_count     = 2
