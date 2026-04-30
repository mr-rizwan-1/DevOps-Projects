terraform {
  backend "s3" {
    bucket = "terraformtfstate129"
    key    = "Terraform/Exercise6/terraform.tfstate"
    region = "us-east-1"
  }
}