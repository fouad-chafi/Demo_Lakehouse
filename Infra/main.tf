terraform {
  backend "s3" {
    bucket         = "tfstate-0749"
    key            = "aws-demo-datalake/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
