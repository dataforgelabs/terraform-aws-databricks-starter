variable "region" {
  description = "AWS region for VPC and Databricks workspace"
  type        = string
}

variable "environment" {
  description = "Prefix for resource names - these should be the same as provided during signup"
  type        = string
}

variable "client" {
  description = "Suffix for resource names - these should be the same as provided during signup"
  type        = string
}

variable "vpc_cidr_full" {
  type = string
}

variable "public_subnet_full" {
  type = string
}

variable "databricks_az1_subnet_full" {
  type = string
}

variable "databricks_az2_subnet_full" {
  type = string
}

variable "existing_vpc_id" {
  type    = string
  default = ""
}

variable "databricks_az1_subnet" {
  type    = string
  default = ""
}


variable "databricks_az2_subnet" {
  type    = string
  default = ""
}

variable "public_subnet" {
  type    = string
  default = ""
}

variable "existing_databricks_az1_subnet_id" {
  type    = string
  default = ""
}

variable "existing_databricks_az2_subnet_id" {
  type    = string
  default = ""
}

variable "existing_public_subnet_id" {
  type    = string
  default = ""
}

variable "existing_public_route_table_id" {
  type    = string
  default = ""
}

variable "existing_internal_route_table_id" {
  type    = string
  default = ""
}

variable "existing_internet_gateway_id" {
  type    = string
  default = ""
}

variable "existing_nat_gateway_id" {
  type    = string
  default = ""
}
