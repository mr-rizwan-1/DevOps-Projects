resource "aws_instance" "Web-Server" {
  ami                    = data.aws_ami.amiID.id # Use the AMI ID from the data source
  instance_type          = "t3.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.dove-sg.id]
  availability_zone      = var.zone1 # Specify the availability zone for the instance 

  # user_data - Cleaner, safer, no SSH dependency
  
  user_data = file("web.sh")

  # Ensure new instances are created before old one is destroyed (for zero downtime deployments)
  # When AMI or user_data changes 
  
  lifecycle {
    create_before_destroy = true
  }

  tags = {
      Name    = "Dove-Web-Server"
      Project = "Dove-Project"
    }
}

#  Save instance details locally after apply

resource "null_resource" "save_output" {
  depends_on = [aws_instanece.Web-Server]

  provisioner "local-exec" {
    command = "bash Scripts/save_output.sh ${aws_instance.Web-Server.id} ${aws_instace.Web-Server.public_ip} ${aws_instance.Web-Server.private_ip} ${aws_instance.Web-Server.availability_zone}"
  }
}

output "WebPublicIP" {
  description = "Public IP of the web server - use this to access the website"
  value = aws_instance.Web-Server.public_ip
}

output "WebPrivateIP" {
  description = "Private IP of the WebServer"
  value = "${aws_instance.Web-Server.private_ip}"
}

output "WebURL" {
  description = "URL to access the Deployed website"
  value = "http://${aws_instance.Web-Server.public_ip}"
}