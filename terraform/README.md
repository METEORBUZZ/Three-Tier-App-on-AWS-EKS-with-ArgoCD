# Multi-Stage Terraform Infrastructure (Dev, Stage, Prod)

This directory contains modular Terraform configurations for provisioning AWS infrastructure (VPC, Subnets, Internet/NAT Gateways, Route Tables, and AWS EKS Kubernetes Cluster) across three isolated environments: **`dev`**, **`stage`**, and **`prod`**.

---

## 💡 What Is This? (Non-Technical Explanation)

If you are new to cloud infrastructure, here is what each piece actually does using a simple real-world analogy:

| Cloud Component | What It Is in Plain English | Real-World Analogy |
| :--- | :--- | :--- |
| **Terraform (`.tf`)** | An automated construction blueprint | Writing down instructions on paper so AWS builds all our servers automatically with one click. |
| **VPC (Virtual Private Cloud)** | Our private cloud network | A secure, gated community inside AWS reserved only for our company. |
| **Internet Gateway (IGW)** | The front door to the internet | The main security gate that allows outside internet visitors to reach our public website. |
| **Public Subnets** | Storefront / Parking area | The public-facing area where web load balancers receive visitors from the internet. |
| **Private Subnets** | The secure back rooms / vaults | Safe internal rooms where our app containers and databases run, protected from direct internet access. |
| **NAT Gateway** | One-way security exit door | Allows our private servers to download security updates from the internet without letting outsiders enter. |
| **EKS (Kubernetes Cluster)** | The Master Brain & Container Manager | Automatically manages our app: restarts containers if they crash and adds more servers when traffic spikes. |
| **Worker Nodes (EC2)** | The worker computers | Virtual computers that do the real work and run the backend, frontend, and database tasks. |
| **IAM Roles & Policies** | Digital security badges | ID badges that give servers permission to talk to AWS services safely. |

---

## 📁 Directory Structure

```text
terraform/
├── dev/                         # Stage 1: Development
│   ├── main.tf                  # AWS Provider + VPC & EKS modules
│   ├── variables.tf             # Input variables
│   ├── terraform.tfvars         # Dev environment values
│   └── outputs.tf               # Cluster endpoints & kubeconfig output
├── stage/                       # Stage 2: Staging / Pre-prod
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   └── outputs.tf
├── prod/                        # Stage 3: Production
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   └── outputs.tf
├── modules/                     # Reusable Core Blueprints
│   ├── vpc/                     # AWS VPC, Subnets, Gateways, Route Tables
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── eks/                     # AWS EKS Cluster, IAM roles, Node Groups
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── README.md                    # Setup & architecture guide
```

---

## ⚙️ Environment Configurations Comparison

| Feature | Development (`dev`) | Staging (`stage`) | Production (`prod`) |
| :--- | :--- | :--- | :--- |
| **Cluster Name** | `todo-dev-eks-cluster` | `todo-stage-eks-cluster` | `todo-prod-eks-cluster` |
| **VPC CIDR** | `10.10.0.0/16` | `10.20.0.0/16` | `10.30.0.0/16` |
| **NAT Gateways** | 1 (Cost-saving) | 1 (Cost-saving) | 2 (Multi-AZ High Availability) |
| **Node Instance Type** | `t3.medium` | `t3.medium` | `t3.large` |
| **Desired Nodes** | 1 | 2 | 3 |
| **Min / Max Nodes** | 1 / 2 | 1 / 3 | 2 / 5 |
| **K8s Version** | 1.29 | 1.29 | 1.29 |
| **State Key** | `todo-app/dev/terraform.tfstate` | `todo-app/stage/terraform.tfstate` | `todo-app/prod/terraform.tfstate` |

---

## 🚀 Quick Start Guide

### 1. Prerequisites
- **Terraform** >= 1.5.0
- **AWS CLI** configured (`aws configure` with permissions for VPC, IAM, EC2, and EKS)
- **kubectl**

### 2. Deploy an Environment (e.g., Dev)

Navigate to the target environment directory:

```bash
cd terraform/dev
# or: cd terraform/stage, cd terraform/prod
```

Initialize Terraform:
```bash
terraform init
```

Preview changes:
```bash
terraform plan
```

Apply and provision the infrastructure:
```bash
terraform apply
```

### 3. Configure `kubectl` for the Cluster

Once `terraform apply` finishes, it outputs the command to configure your local `kubeconfig`:

```bash
# For Dev:
aws eks update-kubeconfig --region us-east-1 --name todo-dev-eks-cluster

# Verify nodes are running:
kubectl get nodes
```

---

## 🔒 Enabling Remote State (S3 + DynamoDB)

By default, Terraform stores state locally. For team collaboration and state locking in CI/CD, enable S3 remote state:

1. Create an S3 bucket and DynamoDB table in AWS:
```bash
aws s3api create-bucket --bucket todo-terraform-state-bucket --region us-east-1
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

2. In `backend.tf` of the relevant environment (`dev`, `stage`, or `prod`), uncomment the `backend "s3"` block:
```hcl
terraform {
  backend "s3" {
    bucket         = "todo-terraform-state-bucket"
    key            = "todo-app/dev/terraform.tfstate" # Adjust per environment
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

3. Reinitialize Terraform to migrate the state:
```bash
terraform init -migrate-state
```

---

## 🧹 Destroying Resources

To tear down an environment to prevent cloud costs:

```bash
cd terraform/environments/dev
terraform destroy
```
