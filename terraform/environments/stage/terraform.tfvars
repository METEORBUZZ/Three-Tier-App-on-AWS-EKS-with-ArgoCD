# ==============================================================================
# STAGE ENVIRONMENT: VARIABLE VALUES (THE ACTUAL SETTINGS)
# ==============================================================================

# AWS Region
aws_region = "us-east-1"

# Stage tag
environment = "stage"

# Cluster name
cluster_name = "todo-stage-eks-cluster"

# Kubernetes version
kubernetes_version = "1.29"

# Network IP range for stage (10.20.x.x)
vpc_cidr = "10.20.0.0/16"

# Single NAT Gateway for stage cost control
single_nat_gateway = true

# Virtual machine hardware size (t3.medium: 2 vCPU, 4GB RAM)
node_instance_types = ["t3.medium"]

# Start with 2 servers, allow scaling between 1 and 3 servers
desired_node_count = 2
min_node_count     = 1
max_node_count     = 3
