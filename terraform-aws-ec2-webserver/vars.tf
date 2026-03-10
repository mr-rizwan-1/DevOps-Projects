variable "region" {
  default = "us-east-1"
}

variable "zone1" {
  default = "us-east-1a"
}

variable "webuser" {
  default = "ubuntu"
}

variable "amiID" {
  type = map(any)
  default = {
    "us-east-1" = "ami-0b6c6ebed2801a5cb"
    "us-east-2" = "ami-06e3c045d79fd65d9"
  }
}