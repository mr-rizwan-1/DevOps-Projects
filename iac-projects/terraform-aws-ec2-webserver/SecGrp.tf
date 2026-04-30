resource "aws_security_group" "dove-sg" {
  name        = "dove-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  #   vpc_id      = aws_vpc.main.id - Defolt VPC is being used, so this line is not needed. If you were to create a custom VPC, you would need to specify the VPC ID here.

  tags = {
    Name = "dove-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "sshfrmomyIP_ipv4" {
  security_group_id = aws_security_group.dove-sg.id
  cidr_ipv4         = "0.0.0.0/0" # Replace with your actual IP address in CIDR notation (e.g.,
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.dove-sg.id
  cidr_ipv4         = "0.0.0.0/0" # Allow HTTP traffic from anywhere
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "AllowAllOutbound_IPv4" {
  security_group_id = aws_security_group.dove-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "AllowAllOutbound_IPv6" {
  security_group_id = aws_security_group.dove-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}