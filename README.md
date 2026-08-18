# AWS IaC Terraform Project

## Overview

This project demonstrates how AWS infrastructure can be designed and deployed using Terraform and Infrastructure as Code (IaC) principles.

The project focuses on creating a simple AWS environment with repeatable, version-controlled infrastructure rather than configuring resources manually in the AWS Console.

## Planned Architecture

The initial architecture includes:

- Amazon VPC
- Public subnet
- Internet Gateway
- EC2 instance
- Security Group

## Architecture Diagram

![Project Architecture](docs/project-architecture.png)

## Infrastructure as Code

Terraform will be used to define, create, update, and remove the AWS infrastructure.

## Project Structure

```text
AWS-IaC-Terraform-Project/
├── docs/
│   ├── architecture.md
│   ├── project-architecture.drawio
│   └── project-architecture.png
├── terraform/
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   └── variables.tf
└── README.md
```

## Project Status

- ✅ **Planning Complete**
- ⏳ Infrastructure Development In Progress
