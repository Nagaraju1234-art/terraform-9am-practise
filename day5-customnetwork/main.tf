#creation of vpc
resource "aws_vpc" "vp" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "cust-vpc"
    }
  
}
#creation of subnet
resource "aws_subnet" "name" {
  vpc_id = aws_vpc.vp.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "subnet"
  }
  
}
#creation of internet gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vp.id
    tags = {
      Name = "cust-igw"
    }

  
}
#creation of route table and edit routes
resource "aws_route_table" "name" {
    vpc_id = aws_vpc.vp.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
  
}
#creation of subnetassociation
resource "aws_route_table_association" "name" {
    route_table_id = aws_route_table.name.id
    subnet_id = aws_subnet.name.id
  
}
#creation of private subnet
resource "aws_subnet" "private" {
    vpc_id = aws_vpc.vp.id
    cidr_block = "10.0.1.0/24"
  tags = {
    Name = "private subnet1"
  }
}
# create EIP
resource "aws_eip" "nat" {
  
}

# create NAT Gateway in public subnet
resource "aws_nat_gateway" "name" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.name.id  # must be public
  tags = {
    Name = "cust-nat"
  }
}

   
 

 #creation of nat route table
  
resource "aws_route_table" "nat" {
    vpc_id = aws_vpc.vp.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.name.id

    }
  
}
#creation of nat subnet association
resource "aws_route_table_association" "nat" {
    route_table_id = aws_route_table.nat.id
    subnet_id = aws_subnet.private.id
  
}
#creation of instance
resource "aws_instance" "dev" {
  ami = "ami-04e08e36e17a21b56"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.name.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]

}


#creation of sg
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  vpc_id      = aws_vpc.vp.id
  tags = {
    Name = "dev_sg"
  }
 ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
}
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1" #all protocols 
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
}