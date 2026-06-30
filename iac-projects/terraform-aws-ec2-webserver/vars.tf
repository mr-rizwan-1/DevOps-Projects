variable "region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "zone1" {
  description = "Availability zone for EC2 instance"
  default     = "us-east-1a"
}

variable "my_ip" {
  description = "Your local machine public IP in CIDR format - used to restrict SSH access"
  type        = string
}

variable "key_name" {
  description = "Name of the AWS key pair"
  default = "dove-key"
}

variable "public_key_path" {
  description = "Path to your local SSH Key file"
  default = "~/.ssh/dove-key.pub"
}

variable "environment" {
  description = "Deployment environment name"
  default     = "dev"
}

variable "project" {
  description = "Deployment project name"
  default     = "Dove-Project"
}

variable "owner" {
  description = "Owner name or team name for resource tracking"
  default     = "rizwaan"
}