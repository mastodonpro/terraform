### DETERMINE ENVIRONMENT ###
variable "ATLAS_WORKSPACE_NAME" {
  # https://support.hashicorp.com/hc/en-us/articles/360022827893-Terraform-workspace-value-is-always-default
  type = string
}

# Terraform Cloud
variable "TFC_OAUTH_TOKEN_ID" {
  type        = string
  description = "The OAuth Token ID of the Terraform Cloud Organisation to access the GitHub App"
  default     = "ot-8LpearcS3vpGFHEL"
}

# Amazon Web Services
variable "AWS_ACCESS_KEY_ID" {
  type        = string
  description = "AWS Access Key ID for the Root Account"
  default     = "AKIAQRSU62EWVDFIBIVN"
}
variable "AWS_SECRET_ACCESS_KEY" {
  type        = string
  description = "AWS Secret Access Key of the Root Account"
  sensitive   = true
}

# GitHub
variable "GITHUB_APP_IP" {
  type        = string
  description = "The id of the GitHub App"
  default     = "276272"
}
variable "GITHUB_APP_INSTALLATION_ID" {
  type        = string
  description = "The Installation id of the GitHub App"
  default     = "32610880"
}
variable "GITHUB_APP_PEM_FILE" {
  type        = string
  description = "The contents of the secret of the GitHub App"
  sensitive   = true
}
