data "aws_caller_identity" "current" {}

locals {
  commonTags = {
    Environment = var.environment_prefix
  }
}

resource "aws_vpc" "main" {
  count                = var.existing_vpc_id == "" ? 1 : 0
  cidr_block           = var.vpc_cidr_full
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    local.commonTags,
    tomap(
      { "Name" = "${local.commonTags.Environment}-Databricks-VPC" }
    )
  )
}