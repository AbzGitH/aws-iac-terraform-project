# CIDR range used by the project VPC

variable "vpc_cidr" {
  description = "CIDR block for the project VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# CIDR range used by the public subnet

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# CIDR range used by database subnet A

variable "database_subnet_a_cidr" {
  description = "CIDR block for database subnet A"
  type        = string
  default     = "10.0.2.0/24"
}

# EC2 instance type used for the web server

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# RDS instance class used for the MySQL database

variable "db_instance_class" {
  description = "RDS database instance class"
  type        = string
  default     = "db.t3.micro"
}

# Storage allocated to the RDS MySQL database in gigabytes

variable "db_allocated_storage" {
  description = "RDS allocated storage in gigabytes"
  type        = number
  default     = 20
}

# Name of the initial RDS MySQL database

variable "db_name" {
  description = "RDS database name"
  type        = string
  default     = "projectdb"
}

# Administrator username for the RDS MySQL database

variable "db_username" {
  description = "RDS database administrator username"
  type        = string
  default     = "admin"
}

# Secure RDS password passed into Terraform without storing it in source code

variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}