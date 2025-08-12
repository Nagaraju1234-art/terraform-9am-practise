provider "aws" {
  region = "us-east-1"
}

# -------------------------
# Security Group for RDS
# -------------------------
resource "aws_security_group" "rds_sg" {
  name        = "my-db-sg"
  description = "Allow MySQL inbound from app layer"
  vpc_id      = "vpc-08ed2048deb9f9be1" # <-- Replace with your VPC ID

  ingress {
    description = "MySQL from app network"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # <-- Replace with your app's network CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MyApp-DB-SG"
  }
}

# -------------------------
# DB Subnet Group
# -------------------------
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = ["subnet-002982ca23e8de8b8", "subnet-0608c72a2f89f4007"] # <-- Replace with your private subnet IDs

  tags = {
    Name = "MyApp-DB-SubnetGroup"
  }
}

# -------------------------
# RDS Instance
# -------------------------
resource "aws_db_instance" "mydb" {
  identifier              = "my-db"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
                   
  username                = "admin"                # <-- Replace with your username
  password                = "StrongPassword123!"   # <-- Replace with a secure password
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  multi_az                = false
  publicly_accessible     = true
  backup_retention_period = 7
  skip_final_snapshot     = true

  tags = {
    Name = "MyApp-RDS"
  }
}


# RDS Read Replica
# -------------------------
resource "aws_db_instance" "mydb_read_replica" {
  identifier              = "my-db-read-replica"
  replicate_source_db     = aws_db_instance.mydb.arn
  instance_class          = "db.t3.micro"
  publicly_accessible     = false
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name

  tags = {
    Name = "MyApp-RDS-ReadReplica"
  }
}