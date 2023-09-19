terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "1.18.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.26.0"
    }
  }
}

provider "aws" {
  region                   = var.region
  access_key               = var.iam_access_key
  secret_key               = var.iam_secret_key
  shared_credentials_files = var.shared_credential_location
  shared_config_files      = var.shared_config_location
}

locals {
  vpc_cidr_full              = var.vpc_cidr_block == "" ? "${var.vpc_first_two_octets}.0.0/16" : var.vpc_cidr_block
  public_subnet_full         = var.public_subnet == "" ? "${var.vpc_first_two_octets}.1.0/24" : var.public_subnet
  databricks_az1_subnet_full = var.databricks_az1_subnet == "" ? "${var.vpc_first_two_octets}.128.0/18" : var.databricks_az1_subnet
  databricks_az2_subnet_full = var.databricks_az2_subnet == "" ? "${var.vpc_first_two_octets}.192.0/18" : var.databricks_az2_subnet
  commonTags = {
    Environment = var.environment_prefix
  }
}

module "networking" {
  source = "./modules/networking"
  environment_prefix                = var.environment_prefix
  region                            = var.region
  vpc_cidr_full                     = local.vpc_cidr_full
  public_subnet_full                = local.public_subnet_full
  databricks_az1_subnet_full        = local.databricks_az1_subnet_full
  databricks_az2_subnet_full        = local.databricks_az2_subnet_full
  existing_vpc_id                   = var.existing_vpc_id
  existing_public_subnet_id         = var.existing_public_subnet_id
  existing_databricks_az1_subnet_id = var.existing_databricks_az1_subnet_id
  existing_databricks_az2_subnet_id = var.existing_databricks_az2_subnet_id
  existing_public_route_table_id    = var.existing_public_route_table_id
  existing_internal_route_table_id  = var.existing_internal_route_table_id
  existing_internet_gateway_id      = var.existing_internet_gateway_id
  existing_nat_gateway_id           = var.existing_nat_gateway_id
}

module "databricks_workspace" {
  source = "./modules/databricks_workspace"
  environment_prefix               = var.environment_prefix
  region                           = var.region
  databricks_account_id            = var.databricks_account_id
  databricks_account_user          = var.databricks_account_user
  databricks_account_password      = var.databricks_account_password
  databricks_client_id             = var.databricks_client_id
  databricks_client_secret         = var.databricks_client_secret
  databricks_workspace_admin_email = var.databricks_workspace_admin_email
  vpc_id                           = module.networking.vpc_id
  databricks_az1_subnet_id         = module.networking.databricks_az1_subnet_id
  databricks_az2_subnet_id         = module.networking.databricks_az2_subnet_id
  security_group_id                = module.networking.security_group_id
}




