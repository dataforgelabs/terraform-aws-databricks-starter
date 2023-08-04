terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "1.18.0"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  commonTags = {
    Environment = var.environment,
    Client      = var.client
  }
}

provider "databricks" {
  alias         = "mws"
  host          = "https://accounts.cloud.databricks.com/"
  username      = var.databricks_account_user
  password      = var.databricks_account_password
  client_id     = var.databricks_client_id
  client_secret = var.databricks_client_secret
  account_id    = var.databricks_account_id
}

resource "databricks_mws_networks" "main" {
  provider           = databricks.mws
  account_id         = var.databricks_account_id
  network_name       = "${local.commonTags.Environment}-mws-network-${local.commonTags.Client}"
  subnet_ids         = [var.databricks_az1_subnet_id, var.databricks_az2_subnet_id]
  vpc_id             = var.vpc_id
  security_group_ids = [var.security_group_id]
}

resource "databricks_mws_workspaces" "main" {
  provider                 = databricks.mws
  account_id               = var.databricks_account_id
  aws_region               = var.region
  workspace_name           = lower(local.commonTags.Environment)
  deployment_name          = lower(local.commonTags.Environment)
  credentials_id           = databricks_mws_credentials.main.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.main.storage_configuration_id
  network_id               = databricks_mws_networks.main.network_id
}