provider "aws" {
  region = "us-east-1"
}

# -------------------------------
# VPC & Subnets
# -------------------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

# Internet Gateway + Route Table
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

# -------------------------------
# Security Groups
# -------------------------------
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id

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

resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Only ALB can talk to EC2
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Optional for SSH
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------------
# ALB + Target Group
# -------------------------------
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/index.html"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# -------------------------------
# Launch Template
# -------------------------------
resource "aws_launch_template" "example" {
  name_prefix   = "example-"
  image_id      = "ami-00ca32bbc84273381" # Replace with your AMI
  instance_type = "t2.micro"

  user_data = base64encode(<<-EOT
              #!/bin/bash
              yum install -y httpd
              echo "Hello from AutoScaling Instance - $(hostname)" > /var/www/html/index.html
              systemctl start httpd
              systemctl enable httpd
            EOT
  )

  network_interfaces {
    security_groups = [aws_security_group.ec2_sg.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ASG-instance"
    }
  }
}

# -------------------------------
# Auto Scaling Group
# -------------------------------
resource "aws_autoscaling_group" "example" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.public1.id, aws_subnet.public2.id]
  health_check_type   = "EC2"

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn] # Attach to ALB

  tag {
    key                 = "Name"
    value               = "ASG-example"
    propagate_at_launch = true
  }
}

