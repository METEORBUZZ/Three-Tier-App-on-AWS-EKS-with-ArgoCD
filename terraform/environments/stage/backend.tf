# ==============================================================================
# STAGE ENVIRONMENT: REMOTE STATE STORAGE (OPTIONAL / RECOMMENDED FOR TEAMS)
# ==============================================================================
# Uncomment this block to store the Stage environment state in AWS S3 with locking.
# ==============================================================================

# terraform {
#   backend "s3" {
#     bucket         = "todo-terraform-state-bucket"
#     key            = "todo-app/stage/terraform.tfstate" # Dedicated file path for Stage
#     region         = "us-east-1"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }
