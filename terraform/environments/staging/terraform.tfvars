# Staging Environment
# Environment-specific Terraform values for staging.
# Portfolio sizing is kept cost-conscious while demonstrating environment separation.

# EC2
instance_type = "t3.micro"

# RDS
db_instance_class    = "db.t3.micro"
db_allocated_storage = 20