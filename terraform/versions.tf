terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure for production.
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "advanced-cicd/dev/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "your-terraform-lock-table"
  #   encrypt        = true
  # }
}

# Configure the AWS provider and apply a consistent baseline tag set to
# taggable resources created by this stack.
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}
