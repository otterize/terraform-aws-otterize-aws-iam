terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    awscc = {
      source = "hashicorp/awscc"
      version = "0.71.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

provider "awscc" {
  region = var.aws_region
}
