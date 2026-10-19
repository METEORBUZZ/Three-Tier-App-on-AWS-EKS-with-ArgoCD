# ==============================================================================
# PROD ENVIRONMENT: CONFIGURATION SETTINGS (INPUT VARIABLES)
# ==============================================================================
# In simple terms:
# Settings for the PROD (Production) environment.
# PROD is tuned for maximum uptime, high availability across multiple zones,
# and high processing power.
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
  default     = "prod"
}

# Cluster name
variable "cluster_name" {
  description = "The name given to the Production Kubernetes cluster"
  type        = string
  default     = "todo-prod-eks-cluster"
}

# Kubernetes version
variable "kubernetes_version" {
  description = "The version of Kubernetes installed on the cluster"
  type        = string
  default     = "1.29"
}

# Prod Network IP Range (10.30.0.0/16 is isolated and distinct)
variable "vpc_cidr" {
  description = "The IP address range for the Production private cloud network"
  type        = string
  default     = "10.30.0.0/16"
}

# High Availability: Set to FALSE in production so AWS creates 2 separate NAT Gateways
# (one per physical data center). If one AWS zone experiences an outage, the other keeps running.
variable "single_nat_gateway" {
  description = "Set to false for production to deploy 2 redundant NAT gateways across availability zones"
  type        = bool
  default     = false
}

# Production hardware size (t3.large: 2 vCPU, 8GB RAM for heavy user load)
variable "node_instance_types" {
  description = "Hardware size for Production worker servers"
  type        = list(string)
  default     = ["t3.large"]
}

# Run 3 worker servers normally for high availability and zero downtime
variable "desired_node_count" {
  description = "Normal number of worker servers to keep running in Production"
  type        = number
  default     = 3
}

# Minimum 2 servers running at all times
variable "min_node_count" {
  description = "The minimum number of worker servers allowed in Production"
  type        = number
  default     = 2
}

# Maximum 5 servers to handle traffic spikes smoothly
variable "max_node_count" {
  description = "The maximum number of worker servers to scale up to during high traffic"
  type        = number
  default     = 5
}
