provider "aws" {

}

resource "aws_s3_bucket" "name" {
    bucket = "civilenginnering"
    
    tags = {
      Name = "civil"
    }
  
}