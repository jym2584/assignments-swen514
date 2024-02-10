output "instance_ip_addr" {
  value = aws_instance.my_server[*].private_ip
}

output "instance_ip_addr_public" {
  value = aws_instance.my_server[*].public_ip
}