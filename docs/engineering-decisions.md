# Engineering Decisions

This document records the key engineering and infrastructure decisions made during Project 2, including the reasoning behind each decision, the risks considered, and the practices used to improve the reliability, security, and maintainability of the Terraform-managed AWS infrastructure.

---

## Terraform Network Module Refactoring

### Engineering Change

The networking configuration was initially defined directly in the root Terraform configuration. As the project developed, the VPC, public subnet, Internet Gateway, route table and route table association were moved into a reusable `network` module.

### Migration Risk

Moving existing Terraform resources into a module changes their Terraform resource addresses. Without migrating the existing state, Terraform can interpret the refactor as instructions to destroy the original resources and create replacements inside the module.

An initial plan exposed this risk by showing infrastructure destruction and recreation that was not intended.

### Resolution

The existing networking resources were migrated to their corresponding module addresses in Terraform state using `terraform state mv`.

The Terraform plan was then reviewed again to confirm that the refactor no longer required unnecessary replacement of the existing networking infrastructure.

### Engineering Lesson

Terraform refactoring must account for both configuration and state. Moving code into a module does not automatically tell Terraform that the new module resources represent infrastructure it already manages.

Reviewing the execution plan before applying changes prevented an unnecessary infrastructure rebuild and allowed the networking configuration to be modularised safely.

---

## Remote Terraform State

### Engineering Decision

Terraform state was configured to use a remote Amazon S3 backend rather than relying on local state as the project's active state storage.

The backend uses the `abs-project2-terraform-state` S3 bucket with the state stored under `project2/terraform.tfstate` in `eu-west-2`. Backend encryption and S3-based state locking are enabled.

### Reasoning

Terraform state records the relationship between the Terraform configuration and the AWS resources it manages. Relying only on local state would make that record dependent on the development machine and increase the risk of state loss or conflicting infrastructure operations.

Remote state provides a central location for the active state, while state locking helps prevent concurrent Terraform operations from modifying it at the same time.

### State Security and Repository Handling

Terraform state and local state backup files are excluded from Git. State is operational data rather than source code and can contain infrastructure metadata that should not be published in the repository.

The Terraform configuration remains version controlled, while the active state is maintained separately in the encrypted S3 backend.

### Engineering Lesson

Infrastructure code and infrastructure state have different lifecycle and security requirements. Separating version-controlled Terraform configuration from remotely managed state provides a safer and more maintainable infrastructure workflow.

---

## Development, Staging and Production Environments

### Engineering Decision

The Terraform project was structured with separate environment-specific variable files for development, staging and production:

- `environments/dev/terraform.tfvars`
- `environments/staging/terraform.tfvars`
- `environments/prod/terraform.tfvars`

The shared Terraform configuration remains in the root project while environment-specific values are supplied through the appropriate variable file.

### Reasoning

Separating environment configuration allows the same Terraform infrastructure definition to be reused while individual environments can use different values where required.

This reflects a standard software development lifecycle approach in which infrastructure changes can progress through Development, UAT/Staging and Production rather than being treated as direct production changes.

For this portfolio project, the environments demonstrate the configuration and promotion structure without unnecessarily deploying three complete copies of the AWS infrastructure and incurring additional cost.

### Production Validation

The production configuration was explicitly evaluated using Terraform before project completion. The resulting plan confirmed that the deployed infrastructure matched the intended production configuration without requiring additional infrastructure changes.

### Engineering Lesson

Environment separation does not require duplicating the Terraform codebase. Shared infrastructure code combined with environment-specific configuration provides a cleaner foundation for controlled testing, promotion and production deployment.

---

## RDS `apply_immediately` Configuration

### Engineering Decision

During development and troubleshooting, the RDS configuration used `apply_immediately = true` so that database changes could take effect without waiting for the next maintenance window.

For the final production-oriented configuration, this was changed to:

`apply_immediately = false`

### Reasoning

Immediate application was useful while actively building and diagnosing the infrastructure because it reduced the delay between a Terraform change and its effect in AWS.

For production infrastructure, however, automatically applying potentially disruptive database modifications immediately is less desirable. Allowing applicable RDS changes to wait for the configured maintenance window provides greater operational control and reduces the risk of an unexpected service interruption.

### Deployment Consideration

Changing the Terraform configuration does not by itself prove that the corresponding AWS change has been applied.

The final Terraform plan must therefore be reviewed before Project 2 is closed. If the configuration produces a pending RDS modification, the change will be evaluated and applied deliberately as part of the final production deployment decision.

### Engineering Lesson

Configuration appropriate during rapid development is not necessarily appropriate for production. Infrastructure settings should be reviewed as a project moves toward production, with operational stability taking priority over development convenience.

---

## Credential Handling

### Engineering Decision

The RDS database password is not stored directly in the Terraform configuration or committed to the Git repository.

The Terraform configuration references the sensitive variable:

`var.db_password`

The variable is declared as a sensitive string, and the password is supplied to Terraform at runtime using the `TF_VAR_db_password` environment variable.

### Reasoning

Hard-coding database credentials in Terraform files would risk exposing them through source control and repository history.

Separating the credential from the Terraform configuration allows the infrastructure code to remain version controlled without publishing the database password.

Marking the variable as sensitive also prevents Terraform from displaying the value unnecessarily in normal CLI output.

### Repository Security

Credential values, Terraform state files and local state backups are not intended to be stored in the Git repository.

This keeps source-controlled infrastructure configuration separate from secrets and operational state.

### Engineering Lesson

Infrastructure as Code should define how credentials are consumed without embedding the credentials themselves. Separating secrets from source code reduces accidental exposure and provides a cleaner foundation for adopting dedicated secret-management services in production environments.

---

## Cost Management and Infrastructure Teardown

### Engineering Decision

After the infrastructure had been successfully deployed, validated and documented, the live AWS resources were intentionally destroyed using Terraform.

The project infrastructure was no longer required to remain continuously deployed once the implementation, architecture, troubleshooting and deployment evidence had been captured.

### Cost Management Rationale

Running cloud infrastructure after a project has completed can continue consuming AWS credits and generate unnecessary cost, particularly for continuously provisioned services such as EC2 and RDS.

The project therefore followed a cost-conscious infrastructure lifecycle:

**Provision → Validate → Evidence → Destroy**

This preserves the technical value of the project while avoiding unnecessary consumption of cloud resources after validation is complete.

### Infrastructure Reproducibility

Destroying the deployed AWS resources does not remove the infrastructure design.

The Terraform configuration, reusable network module, environment-specific configuration and supporting documentation remain version controlled in the Git repository.

Terraform can therefore provision a new instance of the infrastructure when required, with AWS assigning new resource identifiers and Terraform recording the resulting infrastructure in state.

### Engineering Lesson

Infrastructure as Code makes cloud environments reproducible rather than permanently dependent on a specific set of deployed resources.

For temporary development and portfolio environments, intentionally removing infrastructure after testing and evidence capture is both a cost-management practice and a demonstration of the complete infrastructure lifecycle.
