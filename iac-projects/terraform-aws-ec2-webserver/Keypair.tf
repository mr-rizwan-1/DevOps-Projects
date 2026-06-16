resource "aws_key_pair" "dove-key" {
  key_name   = "var.key_name"
  public_key = file("var.public_key_path")

  tags = {
    Name    = "Dove-Key"
    Project = "Dove-Project"
  }

}
