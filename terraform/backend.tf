terraform {
  backend "s3" {
    bucket       = "abs-project2-terraform-state"
    key          = "project2/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
    encrypt      = true
  }
}