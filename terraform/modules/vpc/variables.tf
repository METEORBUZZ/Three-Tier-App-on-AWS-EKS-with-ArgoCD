# ==============================================================================
# VPC MODULE: INPUT VARIABLES (SETTINGS)
# ==============================================================================
# Think of variables as the "settings dial" for our network.
# Instead of hardcoding values, we can customize our network size and name.

# 1. IP Address Range (Network Size)
# This defines how many private IP addresses our cloud network will have.
# "10.0.0.0/16" gives us about 65,000 internal IP addresses for our servers.
variable "vpc_cidr" {
  description = "The IP address range for our private cloud network (e.g., 10.0.0.0/16)"
  type        = string
  default     = "10.0.0.0/16"
}

# 2. Environment Name
# Identifies whether this is for testing (dev), staging (stage), or live customers (prod).
variable "environment" {
  description = "The environment stage name: dev, stage, or prod"
  type        = string
}

# 3. Cluster Name
# The name of our Kubernetes cluster so the network tags can be recognized by AWS.
variable "cluster_name" {
  description = "The name of the Kubernetes (EKS) cluster linked to this network"
  type        = string
}

# 4. Cost vs High Availability Switch (Single NAT Gateway)
# A NAT Gateway costs around $32/month per unit.
# - For dev & stage: true (uses 1 NAT gateway to save money).
# - For prod: false (uses 2 NAT gateways so if one AWS zone fails, the other keeps running).
variable "single_nat_gateway" {
  description = "Set to true to save money with 1 gateway (dev/stage), or false for 2 redundant gateways (prod)"
  type        = bool
  default     = true
}

# 5. Extra Resource Labels (Tags)
# Labels help track which department owns a resource and calculate AWS bills.
variable "tags" {
  description = "Optional extra labels to attach to all network resources"
  type        = map(string)
  default     = {}
}
