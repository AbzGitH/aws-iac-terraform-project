# Public IP address of the EC2 web server

output "ec2_public_ip" {
  description = "Public IP address of the EC2 web server"
  value       = aws_instance.web.public_ip
}

# Connection endpoint of the RDS MySQL database

output "rds_endpoint" {
  description = "Connection endpoint of the RDS MySQL database"
  value       = aws_db_instance.main.endpoint
}