# Development Environment
# Environment-specific Terraform values for development.
# Cost-conscious sizing is used for this portfolio deployment.

# EC2
instance_type = "t3.micro"

# RDS
db_instance_class    = "db.t3.micro"
db_allocated_storage = 20