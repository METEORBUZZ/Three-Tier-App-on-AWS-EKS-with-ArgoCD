# ==============================================================================
# DEV ENVIRONMENT: CONFIGURATION SETTINGS (INPUT VARIABLES)
# ==============================================================================
# In simple terms:
# These are the knobs and dials for the DEV (Development) environment.
# DEV is optimized for low cost and fast experimentation.
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
  default     = "dev"
}

# The name of our Dev Kubernetes cluster
variable "cluster_name" {
  description = "The name given to the Dev Kubernetes cluster"
  type        = string
  default     = "todo-dev-eks-cluster"
}

# Kubernetes software version
variable "kubernetes_version" {
  description = "The version of Kubernetes installed on the cluster"
  type        = string
  default     = "1.29"
}

# Dev Network IP Range (10.10.0.0/16 is isolated and won't clash with Stage or Prod)
variable "vpc_cidr" {
  description = "The IP address range for the Dev private cloud network"
  type        = string
  default     = "10.10.0.0/16"
}

# Cost-saver: Dev uses only 1 NAT Gateway to cut AWS bills
variable "single_nat_gateway" {
  description = "Use 1 NAT Gateway in dev to save cloud hosting costs"
  type        = bool
  default     = true
}

# Computer hardware size for dev testing (t3.medium: 2 CPUs, 4GB RAM)
variable "node_instance_types" {
  description = "Hardware size for Dev worker servers"
  type        = list(string)
  default     = ["t3.medium"]
}

# Start with just 1 worker server to keep costs low
variable "desired_node_count" {
  description = "How many worker servers to keep running normally in Dev"
  type        = number
  default     = 1
}

# Minimum 1 server
variable "min_node_count" {
  description = "The minimum number of worker servers allowed in Dev"
  type        = number
  default     = 1
}

# Maximum 2 servers during busy tests
variable "max_node_count" {
  description = "The maximum number of worker servers to scale up to during Dev tests"
  type        = number
  default     = 2
}
