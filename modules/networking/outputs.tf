output "vpc_id" {
  value = var.existing_vpc_id == "" ? aws_vpc.main[0].id : var.existing_vpc_id
}

output "databricks_az1_subnet_id" {
  value = var.existing_databricks_az1_subnet_id == "" ? aws_subnet.databricks_az1[0].id : var.existing_databricks_az1_subnet_id
}

output "databricks_az2_subnet_id" {
  value = var.existing_databricks_az2_subnet_id == "" ? aws_subnet.databricks_az2[0].id : var.existing_databricks_az2_subnet_id
}

output "security_group_id" {
  value = aws_security_group.main.id
}