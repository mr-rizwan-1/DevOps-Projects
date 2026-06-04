resource "aws_security_group" "dove-sg" {
  name        = "dove-sg"
  description = "Security group for Dove web server - SSH restricted to admin IP, HTTP open"

  tags = {
    Name = "dove-sg"
    Project = "Terraform EC2 Webserver"
  }
}

# SSH access - restricted to yout IP only
resource "aws_vpc_security_group_ingress_rule" "sshfrmomyIP_ipv4" {
  security_group_id = aws_security_group.dove-sg.id
  cidr_ipv4         = "${var.my_ip}/32" # Restrict SSH access to your IP only
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

  tags = {
    Name = "SSH-from-admin-only"
  }
}

# HTTP access - open to everyone (this is a public web server)

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.dove-sg.id
  cidr_ipv4         = "0.0.0.0/0" # Allow HTTP traffic from anywhere
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80

  tags = {
    Name = "Allow-HTTP-from-anywhere"
  }
}

# Outbound - all traffic allowed (IPv4)

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_ipv4" {
  security_group_id = aws_security_group.dove-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Outbound - all traffic allowed (IPv6)

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_ipv6" {
  security_group_id = aws_security_group.dove-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}