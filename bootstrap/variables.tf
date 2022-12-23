### DETERMINE ENVIRONMENT ###
variable "ATLAS_WORKSPACE_NAME" {
  # https://support.hashicorp.com/hc/en-us/articles/360022827893-Terraform-workspace-value-is-always-default
  type = string
}
variable "TFC_OAUTH_TOKEN_ID" {
  type        = string
  description = "The OAuth Token ID of the Terraform Cloud Organisation to access the GitHub App"
  default     = "ot-8LpearcS3vpGFHEL"
}

### DEFINE ENVIRONMENT SPECIFIC VARIABLES ###
variable "domain_map" {
  type        = map(any)
  description = "Map of environment to domain."
  default = {
    staging    = "mastodon-st.com"
    production = "mastodonpro.com"
  }
}
