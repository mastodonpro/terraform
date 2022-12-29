### DETERMINE ENVIRONMENT ###
variable "ATLAS_WORKSPACE_NAME" {
  # https://support.hashicorp.com/hc/en-us/articles/360022827893-Terraform-workspace-value-is-always-default
  type = string
}
locals {
  #workspace_name = regex("\\d_(.+)$", var.ATLAS_WORKSPACE_NAME)[0]
  workspace_name = "common"
}

# GitHub (populated via variable sets defined in bootstrap)
variable "GITHUB_APP_ID" {
  type        = string
  description = "The id of the GitHub App"
}
variable "GITHUB_APP_INSTALLATION_ID" {
  type        = string
  description = "The Installation id of the GitHub App"
}
variable "GITHUB_APP_PEM_FILE" {
  type        = string
  description = "The contents of the secret of the GitHub App"
}
