
# EC2

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_key_pair" "project2" {
  key_name   = "project2-ec2-key"
  public_key = file("~/.ssh/project2-ec2.pub")

  tags = {
    Name = "project2-ec2-key"
  }
}

resource "aws_instance" "web" {
  ami                    = "ami-0c0513a2cd4e8e89c"
  instance_type          = var.instance_type
  key_name               = aws_key_pair.project2.key_name
  subnet_id              = module.network.public_subnet_id
  vpc_security_group_ids = [aws_security_group.ec2.id]

  tags = {
    Name = "project2-ec2"
  }
}

resource "aws_security_group" "ec2" {
  name        = "project2-ec2-sg"
  description = "Allow SSH access to EC2"
  vpc_id      = module.network.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project2-ec2-sg"
  }
}

# RDS

resource "aws_subnet" "database" {
  vpc_id            = module.network.vpc_id
  cidr_block        = var.database_subnet_a_cidr
  availability_zone = "eu-west-2b"

  tags = {
    Name = "project2-database-subnet"
  }
}

resource "aws_subnet" "database_b" {
  vpc_id            = module.network.vpc_id
  cidr_block        = var.database_subnet_b_cidr
  availability_zone = "eu-west-2a"

  tags = {
    Name = "project2-database-subnet-b"
  }
}

resource "aws_db_subnet_group" "main" {
  name = "project2-db-subnet-group"

  subnet_ids = [
    aws_subnet.database.id,
    aws_subnet.database_b.id
  ]

  tags = {
    Name = "project2-db-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name        = "project2-rds-sg"
  description = "Allow MySQL access from EC2"
  vpc_id      = module.network.vpc_id

  ingress {
    description     = "MySQL from EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project2-rds-sg"
  }
}

resource "aws_db_instance" "main" {
  identifier        = "project2-rds-v2"
  apply_immediately = true
  engine            = "mysql"
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 1
  deletion_protection     = false
  skip_final_snapshot     = true

  tags = {
    Name = "project2-rds"
  }
}

# Network module
# Uses the reusable network configuration stored in modules/network.

module "network" {
  source = "./modules/network"

  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
}