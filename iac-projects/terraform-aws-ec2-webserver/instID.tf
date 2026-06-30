# This is the Data source to get the latest AMI ID for Ubuntu 22.04 LTS (Jammy Jellyfish) from Canonical. 
# The filters ensure that we get the correct AMI based on the name pattern and virtualization type.

data "aws_ami" "amiID" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical

}

# Output blocks are used to display the results after the Terraform apply command is executed. 
# Here, we are outputting the AMI ID that we retrieved using the data source.

output "latest_ami_id" {
  description = "Latest Ubuntu 22.04 AMI ID fetched from Canonical"
  value       = data.aws_ami.amiID.id

}
