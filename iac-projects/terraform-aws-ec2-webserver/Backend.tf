terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      virsion = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "dove-project-tfstate"
    key            = "Terraform/ec2-webserver/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }

}
