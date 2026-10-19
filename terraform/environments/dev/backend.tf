# ==============================================================================
# DEV ENVIRONMENT: REMOTE STATE STORAGE (OPTIONAL / RECOMMENDED FOR TEAMS)
# ==============================================================================
# What is Terraform State?
# Terraform keeps an inventory file (state file) recording everything it built.
# By default, it saves locally on your computer.
#
# When multiple teammates or CI/CD pipelines (like Jenkins) work together,
# you uncomment this block so the inventory is safely stored in an AWS S3 bucket,
# and DynamoDB prevents two people from applying changes at the exact same second.
# ==============================================================================

# terraform {
#   backend "s3" {
#     bucket         = "todo-terraform-state-bucket" # AWS S3 folder storing the inventory
#     key            = "todo-app/dev/terraform.tfstate" # Dedicated file path for Dev stage
#     region         = "us-east-1"                     # Region where the S3 bucket is located
#     dynamodb_table = "terraform-locks"                # Table used to lock state during changes
#     encrypt        = true                             # Scramble the file with military-grade encryption
#   }
# }
