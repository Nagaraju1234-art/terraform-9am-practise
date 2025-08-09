

# ---------------- VPC ----------------
resource "aws_vpc" "cust_vpc" {
  cidr_block = var.aws_vpc
  tags = {
    Name = "cust-vpc"
  }
}

# ---------------- Public Subnet ----------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.cust_vpc.id
  cidr_block              = var.aws_subnet_public
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

# ---------------- Private Subnet ----------------
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.cust_vpc.id
  cidr_block        = var.aws_subnet_private
  availability_zone = "us-west-2b"
  tags = {
    Name = "private-subnet"
  }
}

# ---------------- Internet Gateway ----------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.cust_vpc.id
  tags = {
    Name = "cust-igw"
  }
}

# ---------------- Public Route Table ----------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.cust_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "cust-public-rt"
  }
}

# ---------------- Associate Public Subnet with Route Table ----------------
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# ---------------- Elastic IP for NAT Gateway ----------------
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# ---------------- NAT Gateway in Public Subnet ----------------
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "cust-nat"
  }
}

# ---------------- Private Route Table ----------------
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.cust_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "cust-private-rt"
  }
}

# ---------------- Associate Private Subnet with Route Table ----------------
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}

# ---------------- Security Group ----------------
resource "aws_security_group" "allow_tls" {
  name   = "allow_tls"
  vpc_id = aws_vpc.cust_vpc.id

  tags = {
    Name = "dev-sg"
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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

# ---------------- EC2 Instance in Public Subnet ----------------
resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.aws_instance
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]

  tags = {
    Name = "cust-ec2"
  }
}
