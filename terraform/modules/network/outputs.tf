# Network module outputs
# Exposes key network resource IDs for use by other parts of the infrastructure.

output "vpc_id" {
  description = "ID of the VPC created by the network module"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet created by the network module"
  value       = aws_subnet.public.id
}