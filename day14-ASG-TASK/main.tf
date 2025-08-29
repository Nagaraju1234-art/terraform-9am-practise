provider "aws" {
  region = "us-east-1"
}

# Security Group for EC2
resource "aws_security_group" "asg_sg" {
  name        = "asg-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch Template (preferred over Launch Config)
resource "aws_launch_template" "example" {
  name_prefix   = "example-"
  image_id      = "ami-00ca32bbc84273381" # Replace with your AMI
  instance_type = "t2.micro"

  network_interfaces {
    security_groups = [aws_security_group.asg_sg.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ASG-instance"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "example" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = [aws_subnet.public1.id, aws_subnet.public2.id] # Place in 2 subnets
  health_check_type    = "EC2"

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ASG-example"
    propagate_at_launch = true       # Apply to all EC2 instances created by ASG
  }
}

# VPC & Subnets (for demo)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true   # Give instances public IPs automatically
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

