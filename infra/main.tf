terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30"
    }
  }

  backend "s3" {
    bucket         = "tfstate-0749"
    key            = "aws-demo-datalake/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  bucket_name    = var.s3_bucket_name != "" ? var.s3_bucket_name : "${var.project_name}-${data.aws_caller_identity.current.account_id}"
  raw_prefix     = "raw_
