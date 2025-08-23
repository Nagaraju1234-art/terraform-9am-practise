variable "ingress_rules" {
  default = {
    22   = "10.0.0.0/24"    # SSH
    80   = "0.0.0.0/0"      # HTTP
    443  = "192.168.1.0/24" # HTTPS
  }
}
resource "aws_security_group" "example" {
  name        = "example-sg"
  description = "SG with simplified rules"


  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = tonumber(ingress.key)
      to_port     = tonumber(ingress.key)
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-sg"
  }
}
