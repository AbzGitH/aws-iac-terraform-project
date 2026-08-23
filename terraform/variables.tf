# Secure RDS password passed into Terraform without storing it in source code

variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}