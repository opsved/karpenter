terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.59.0"
    }
  }
}

provider "aws" {
  # Configuration options
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
  # token      = var.aws_token
  profile = var.aws_profile
  region  = var.aws_region
}