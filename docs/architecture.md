# AWS IaC Terraform Project — Architecture

## Architecture

![AWS Infrastructure Architecture](project-architecture.png)

## Components

- **VPC** — Isolated network containing the deployed AWS infrastructure.
- **Public Subnet** — Hosts the EC2 instance and provides Internet-facing connectivity.
- **Internet Gateway** — Provides Internet access for resources using the public route.
- **Route Table** — Routes public subnet traffic through the Internet Gateway.
- **EC2 Security Group** — Restricts SSH access to the configured trusted CIDR.
- **EC2 Instance** — Amazon Linux virtual machine deployed in the public subnet.
- **Database Subnets** — Two subnets across separate Availability Zones that form the RDS DB subnet group.
- **DB Subnet Group** — Groups the two database subnets for RDS placement.
- **RDS Security Group** — Allows MySQL traffic on port 3306 from the EC2 security group only.
- **RDS MySQL Instance** — Private database instance with public accessibility disabled.

## Infrastructure as Code

The infrastructure is defined and managed using Terraform rather than being manually provisioned through the AWS Console. Reusable networking is separated into a Terraform network module, while environment-specific values are maintained for development, staging, and production.

## Environment Separation

Separate Terraform variable files are maintained for:

- Development
- Staging
- Production

This demonstrates an SDLC-style Development → Staging → Production structure, with environment-specific Terraform configuration managed through separate variable files.

## Network and Security Design

The EC2 instance is deployed in the public subnet and uses a security group with restricted SSH ingress.

The RDS instance uses two database subnets across separate Availability Zones. It is not publicly accessible, and its security group permits MySQL traffic on port 3306 only from the EC2 security group.

This creates the intended access path:

**Internet → EC2 → RDS**

Direct public access to the RDS database is not permitted.
