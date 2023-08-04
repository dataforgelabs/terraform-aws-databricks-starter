variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "client" {
  type = string
}

variable "databricks_account_id" {
  type = string
  default = ""
}

variable "databricks_account_user" {
  type    = string
  default = ""
}

variable "databricks_account_password" {
  type    = string
  default = ""
}

variable "databricks_client_id" {
  type    = string
  default = ""
}

variable "databricks_client_secret" {
  type    = string
  default = ""
}

variable "vpc_id" {
  type = string
}

variable "databricks_az1_subnet_id" {
  type = string
}

variable "databricks_az2_subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}