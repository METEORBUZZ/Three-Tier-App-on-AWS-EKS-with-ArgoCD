# ==============================================================================
# STAGE ENVIRONMENT: CONFIGURATION SETTINGS (INPUT VARIABLES)
# ==============================================================================
# In simple terms:
# Settings for the STAGE environment.
# STAGE is our pre-production rehearsal stage to test real load and deployments.
# ==============================================================================

# Geographic AWS location
variable "aws_region" {
  description = "AWS geographic data center region"
  type        = string
  default     = "us-east-1"
}

# Stage name
variable "environment" {
  description = "The name of this deployment stage"
  type        = string
  default     = "stage"
}

# Cluster name
variable "cluster_name" {
  description = "The name given to the Stage Kubernetes cluster"
  type        = string
  default     = "todo-stage-eks-cluster"
}

# Kubernetes version
variable "kubernetes_version" {
  description = "The version of Kubernetes installed on the cluster"
  type        = string
  default     = "1.29"
}

# Stage Network IP Range (10.20.0.0/16 is distinct from Dev and Prod)
variable "vpc_cidr" {
  description = "The IP address range for the Stage private cloud network"
  type        = string
  default     = "10.20.0.0/16"
}

# Single NAT Gateway to balance reliability and cost in staging
variable "single_nat_gateway" {
  description = "Set to true to use 1 NAT gateway for stage cost control"
  type        = bool
  default     = true
}

# Computer hardware size (t3.medium: 2 vCPU, 4GB RAM)
variable "node_instance_types" {
  description = "Hardware size for Stage worker servers"
  type        = list(string)
  default     = ["t3.medium"]
}

# Start with 2 worker servers for testing multi-instance apps
variable "desired_node_count" {
  description = "Normal number of worker servers to keep running in Stage"
  type        = number
  default     = 2
}

# Minimum 1 server
variable "min_node_count" {
  description = "The minimum number of worker servers allowed in Stage"
  type        = number
  default     = 1
}

# Maximum 3 servers during load tests
variable "max_node_count" {
  description = "The maximum number of worker servers to scale up to during Stage tests"
  type        = number
  default     = 3
}
