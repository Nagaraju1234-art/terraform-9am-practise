provider "aws" {
  region = "us-east-1"
}

# 1️⃣ Create IAM User
resource "aws_iam_user" "demo_user" {
  name = "demo-user"
}

# 2️⃣ Create IAM Policy
resource "aws_iam_policy" "demo_policy" {
  name        = "demo-policy"
  description = "Policy for EC2 to access S3 and CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# 3️⃣ Attach Policy to IAM User
resource "aws_iam_user_policy_attachment" "demo_user_attach" {
  user       = aws_iam_user.demo_user.name
  policy_arn = aws_iam_policy.demo_policy.arn
}

# 4️⃣ IAM Role for EC2 Instance
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# 5️⃣ Attach Policy to Role (EC2 will use this role)
resource "aws_iam_role_policy_attachment" "ec2_role_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.demo_policy.arn
}

# 6️⃣ Instance Profile (wrapper around IAM Role for EC2)
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# 7️⃣ Launch EC2 with IAM Role
resource "aws_instance" "demo_ec2" {
  ami           = "ami-00ca32bbc84273381" # Replace with your region’s AMI
  instance_type = "t2.medium"

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "Demo-EC2"
  }
}
