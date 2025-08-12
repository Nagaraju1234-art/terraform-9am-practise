resource "aws_instance" "name" {
  ami = "ami-0de716d6197524dd9"
  instance_type = "t2.medium"
  availability_zone = "us-east-1d"
  tags = {
    Name = "nag"
  }

}
resource "aws_s3_bucket" "name" {
    bucket = "rajacivillbrce"
  
}