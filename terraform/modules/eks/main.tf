# ==============================================================================
# EKS MODULE: KUBERNETES CLUSTER & WORKER NODES BLUEPRINT
# ==============================================================================
# In simple terms:
# This file sets up:
#   1. The Cluster "Brain" (Control Plane): Managed by AWS, oversees all apps.
#   2. Security Badges (IAM Roles): Allows servers to talk to AWS securely.
#   3. Worker Servers (Node Group): The actual computers that run our app containers.
# ==============================================================================

# ------------------------------------------------------------------------------
# STEP 1: Security Badge for the Cluster Brain (Control Plane IAM Role)
# In AWS, every service needs a permission badge (IAM Role) before it is allowed
# to manage resources. This badge gives EKS permission to manage networking and disks.
# ------------------------------------------------------------------------------
resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"

  # This policy tells AWS: "Allow the EKS service to wear this security badge"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-cluster-role"
      Environment = var.environment
    }
  )
}

# Attach standard AWS permission rules to the cluster security badge
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

# ------------------------------------------------------------------------------
# STEP 2: The EKS Cluster "Brain" (Control Plane)
# This is the master coordinator. AWS handles high availability, backups,
# and updates for this master brain behind the scenes.
# ------------------------------------------------------------------------------
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true # Allow internal worker nodes to talk to the brain securely
    endpoint_public_access  = true # Allow developers to run 'kubectl' commands from their terminal
  }

  # Ensure the security badges are attached before AWS attempts to build the cluster
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController
  ]

  tags = merge(
    var.tags,
    {
      Name        = var.cluster_name
      Environment = var.environment
    }
  )
}

# ------------------------------------------------------------------------------
# STEP 3: Security Badge for Worker Servers (Node Group IAM Role)
# The worker servers need permission to download container images from AWS registries
# and communicate with the EKS cluster master brain.
# ------------------------------------------------------------------------------
resource "aws_iam_role" "node_group" {
  name = "${var.cluster_name}-node-group-role"

  # This policy tells AWS: "Allow EC2 virtual computers to wear this badge"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-node-group-role"
      Environment = var.environment
    }
  )
}

# Standard permission rules for worker servers:
# Rule 1: Allows worker server to join the EKS cluster
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
}

# Rule 2: Allows worker server to assign private IP addresses to application containers
resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group.name
}

# Rule 3: Allows worker server to download Docker images from AWS Elastic Container Registry (ECR)
resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
}

# ------------------------------------------------------------------------------
# STEP 4: The Worker Server Fleet (Managed Node Group)
# These are the actual EC2 virtual computers that do the real work.
# AWS automatically manages OS updates, security patches, and auto-scaling.
# ------------------------------------------------------------------------------
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-managed-nodes"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.node_subnet_ids # Placed safely in private subnets!

  # Computer hardware size (CPU & Memory)
  instance_types = var.node_instance_types

  # Auto-scaling rules: How many computers to run
  scaling_config {
    desired_size = var.desired_node_count # Normal day-to-day count
    max_size     = var.max_node_count     # Maximum during high spikes
    min_size     = var.min_node_count     # Minimum safety baseline
  }

  # When updating computers, only restart 1 computer at a time to prevent downtime
  update_config {
    max_unavailable = 1
  }

  # Ensure all permissions exist before booting the computers
  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly
  ]

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-node"
      Environment = var.environment
    }
  )
}
