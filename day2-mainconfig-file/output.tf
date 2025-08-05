output "public-ip" {
  value = aws_instance.dev.public_ip
}

output "private-ip" {
 value = aws_instance.dev.private_ip
  
}