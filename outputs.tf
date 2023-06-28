output "workspace_url" {
    value = module.databricks_workspace.workspace_url
    description = "URL used to login and access the Databricks workspace. For first time login, use the root Databricks account user that was used for the Terraform run."
}

output "instance_profile_arn" {
    value = module.databricks_workspace.instance_profile_arn
    description = "Instance profile that has access to the Datalake bucket deployed by Terraform. This will be used to give DataForge jobs access to the datalake."
}