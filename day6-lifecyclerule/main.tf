resource "aws_instance" "name" {
  ami = "ami-0de716d6197524dd9"
  instance_type = "t2.medium"
  availability_zone = "us-east-1d"
  tags = {
    Name = "nag"
  }
  lifecycle {
    ignore_changes = [ tags, ]
    prevent_destroy = true
    create_before_destroy = true
  }
}
