locals {
  instance_type="t2.micro"
  region="us-east-1"
  ami="ami-08a6efd148b1f7504"
  name="nag"
}
provider "aws" {
  region = local.region
}
resource "aws_instance" "name" {
    ami = local.ami
  instance_type = local.instance_type
  tags = {
    Name = local.name
  }
}