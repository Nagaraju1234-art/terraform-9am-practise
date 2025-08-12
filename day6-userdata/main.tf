provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "name" {
  ami = "ami-0de716d6197524dd9"
  instance_type = "t2.medium"
  availability_zone = "us-east-1c"
  tags = {
    Name = "test"
  }
user_data = file("test.th")
}