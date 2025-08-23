resource "aws_instance" "name" {
    ami = "ami-00ca32bbc84273381"
    instance_type = "t3.micro"
    tags = {
      Name = "ec2"
    }
  
}
resource "aws_s3_bucket" "name" {
  
  bucket = "rajalbrceit"
}
resource "aws_iam_user" "name" {
    name = "user2"
}



resource "aws_iam_user_policy_attachment" "ec2_full_access" {
  user       = "user2"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_user_policy_attachment" "s3_full_access" {
  user       = "user2"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_user_policy_attachment" "cloudwatch_full_access" {
  user       = "user2"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}
