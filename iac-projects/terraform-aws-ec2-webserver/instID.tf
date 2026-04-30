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

output "instance_id" {
  description = "AMI ID of Ubuntu instance"
  value       = data.aws_ami.amiID.id

}
