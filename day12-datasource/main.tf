
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"] # Official AWS AMIs

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
data "aws_subnet" "name" {
  filter {
    name   = "tag:Name"
    values = ["dev"]
  }
}

output "subnet_id" {
  value = data.aws_subnet.name.id
}

# Use the AMI ID in an EC2 instance
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  tags = {
    Name = "web-server"
  }
}

# Output the AMI ID
output "ami_id" {
  value = data.aws_ami.amazon_linux.id
}



# Lookup AMI created in your account
# data "aws_ami" "self" {
#   most_recent = true
#   owners      = [self]

#   filter {
#     name   = "tag:Name"
#     values = ["dev"]
#   }
# }
