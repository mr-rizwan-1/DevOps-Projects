resource "aws_instance" "Web-Server" {
  ami                    = var.amiID[var.region] # Use the AMI ID based on the selected region
  instance_type          = "t3.micro"
  key_name               = "dove-key"
  vpc_security_group_ids = [aws_security_group.dove-sg.id]
  availability_zone      = var.zone1 # Specify the availability zone for the instance

  tags = {
    Name    = "Dove-Web-Server"
    Project = "Dove-Project"
  }

  # User data script to install and start a web server (e.g., Apache)

  connection {
    type        = "ssh"
    user        = var.webuser
    private_key = file("dovekey")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "web.sh"
    destination = "/tmp/web.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/web.sh",
      "sudo /tmp/web.sh"
    ]
  }

  provisioner "local-exec" {
    command = "bash Scripts/save_output.sh ${self.id} ${self.public_ip} ${self.private_ip}"
  }

}

resource "aws_ec2_instance_state" "web_server_state" {
  instance_id = aws_instance.Web-Server.id
  state       = "running"
}

output "WebPublicIP" {
  description = "Public IP of Ubuntu instance"
  value       = aws_instance.Web-Server.public_ip
}

output "WebPrivateIP" {
  description = "Private IP of Ubuntu instance"
  value       = aws_instance.Web-Server.private_ip
}