provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "Dove-Project"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = var.owner
    }
  }
}
#