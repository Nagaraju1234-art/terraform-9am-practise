provider "aws" {
    region = "us-east-1"
    
  
}
provider "aws" {
    region = "us-west-2"
    alias = "dev"
  profile = "user1"
}
resource "aws_instance" "name" {
   ami = "ami-08a6efd148b1f7504"
  instance_type = "t2.micro"
}

resource "aws_s3_bucket" "name" {
    bucket = "hagshjajgshsj"
   provider = aws.dev
  
}