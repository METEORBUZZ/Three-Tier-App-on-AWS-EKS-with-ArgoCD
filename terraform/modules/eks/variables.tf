# ==============================================================================
# EKS MODULE: INPUT VARIABLES (SETTINGS)
# ==============================================================================
# What is EKS?
# EKS (Elastic Kubernetes Service) is AWS's automated system for managing our
# app containers. Instead of us manually managing 10 servers, EKS automatically
# restarts crashed containers, scales up when lots of users visit, and spreads
# traffic evenly.
# ==============================================================================

# 1. Cluster Name
# The unique name for this Kubernetes cluster in your AWS account.
variable "cluster_name" {
  description = "The name of the Kubernetes cluster (e.g., todo-dev-eks-cluster)"
  type        = string
}

# 2. Environment Stage
# dev (testing), stage (pre-release), or prod (live customers).
variable "environment" {
  description = "The environment stage name (dev, stage, or prod)"
  type        = string
}

# 3. Kubernetes Version
# The version number of the Kubernetes software running inside AWS.
variable "kubernetes_version" {
  description = "The version of Kubernetes software to install (e.g., 1.29)"
  type        = string
  default     = "1.29"
}

# 4. Control Plane Subnets
# Subnet IDs where AWS will place the cluster brain (management servers).
variable "subnet_ids" {
  description = "Subnet IDs for the EKS control plane (management nodes)"
  type        = list(string)
}

# 5. Worker Node Subnets
# Subnet IDs where our actual application server computers will live (private subnets).
variable "node_subnet_ids" {
  description = "Subnet IDs for the worker nodes (usually private subnets for security)"
  type        = list(string)
}

# 6. Computer Hardware Size (Instance Types)
# Defines how much CPU and RAM each worker server gets.
# - t3.medium: 2 CPUs, 4GB RAM (great balance of cost and power for dev/stage)
# - t3.large:  2 CPUs, 8GB RAM (more capacity for production workloads)
variable "node_instance_types" {
  description = "The virtual machine hardware size for worker nodes (e.g., t3.medium)"
  type        = list(string)
  default     = ["t3.medium"]
}

# 7. Desired Server Count
# How many worker computers should be running normally right now.
variable "desired_node_count" {
  description = "The normal number of worker servers to keep running"
  type        = number
  default     = 2
}

# 8. Minimum Server Count
# The lowest number of worker computers allowed (to make sure the app never goes down).
variable "min_node_count" {
  description = "The minimum number of worker servers allowed when traffic is low"
  type        = number
  default     = 1
}

# 9. Maximum Server Count
# The highest number of worker computers allowed when lots of users are using the app.
variable "max_node_count" {
  description = "The maximum number of worker servers to scale up to during high traffic"
  type        = number
  default     = 4
}

# 10. Additional Labels (Tags)
variable "tags" {
  description = "Optional extra labels to attach to all EKS resources"
  type        = map(string)
  default     = {}
}
