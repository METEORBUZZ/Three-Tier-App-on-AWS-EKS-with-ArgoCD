# ==============================================================================
# PROD ENVIRONMENT: REMOTE STATE STORAGE (HIGHLY RECOMMENDED FOR PRODUCTION)
# ==============================================================================
# In production, never keep state files on a single engineer's laptop.
# Uncomment this block to store production state securely in AWS S3 with
# DynamoDB write-locking.
# ==============================================================================

# terraform {
#   backend "s3" {
#     bucket         = "todo-terraform-state-bucket" # Secure cloud bucket
#     key            = "todo-app/prod/terraform.tfstate" # Dedicated file path for Prod
#     region         = "us-east-1"                     # AWS region of the bucket
#     dynamodb_table = "terraform-locks"                # Table used to lock state
#     encrypt        = true                             # Enforce server-side encryption
#   }
# }
