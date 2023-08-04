output "workspace_url" {
  value = databricks_mws_workspaces.main.workspace_url
}

output "instance_profile_arn" {
  value = aws_iam_instance_profile.main.arn
}