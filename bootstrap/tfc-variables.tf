### VARIABLE SETS
# AWS staging
resource "tfe_variable_set" "aws_staging" {
  name         = "AWS Credentials - staging"
  description  = "AWS Access Key ID and Secret Access Key."
  organization = data.tfe_organization.mastodonpro.name
}
resource "tfe_variable" "aws_access_key_id_staging" {
  key             = "AWS_ACCESS_KEY_ID"
  description     = "AWS Access Key ID - staging"
  value           = aws_iam_access_key.terraform_staging.id
  category        = "env"
  variable_set_id = tfe_variable_set.aws_staging.id
}
resource "tfe_variable" "aws_secret_access_key_staging" {
  key             = "AWS_SECRET_ACCESS_KEY"
  description     = "AWS Secret Access Key - staging"
  value           = aws_iam_access_key.terraform_staging.secret
  category        = "env"
  sensitive       = true
  variable_set_id = tfe_variable_set.aws_staging.id
}
# AWS production
resource "tfe_variable_set" "aws_production" {
  name         = "AWS Credentials - production"
  description  = "AWS Access Key ID and Secret Access Key."
  organization = data.tfe_organization.mastodonpro.name
}
resource "tfe_variable" "aws_access_key_id_production" {
  key             = "AWS_ACCESS_KEY_ID"
  description     = "AWS Access Key ID - production"
  value           = aws_iam_access_key.terraform_production.id
  category        = "env"
  variable_set_id = tfe_variable_set.aws_production.id
}
resource "tfe_variable" "aws_secret_access_key_production" {
  key             = "AWS_SECRET_ACCESS_KEY"
  description     = "AWS Secret Access Key - production"
  value           = aws_iam_access_key.terraform_production.secret
  category        = "env"
  sensitive       = true
  variable_set_id = tfe_variable_set.aws_production.id
}

# GitHub App
resource "tfe_variable_set" "github" {
  name         = "GitHub App"
  description  = "Environment variables required for the GitHub provider to authenticate with the GitHub App."
  organization = data.tfe_organization.mastodonpro.name
}
resource "tfe_variable" "github_app_ip" {
  key             = "GITHUB_APP_IP"
  description     = "The id of the GitHub App"
  value           = var.GITHUB_APP_IP
  category        = "terraform"
  variable_set_id = tfe_variable_set.github.id
}
resource "tfe_variable" "github_app_installation_id" {
  key             = "GITHUB_APP_INSTALLATION_ID"
  description     = "The Installation id of the GitHub App"
  value           = var.GITHUB_APP_INSTALLATION_ID
  category        = "terraform"
  variable_set_id = tfe_variable_set.github.id
}
# we need a terraform variable because of newlines
resource "tfe_variable" "github_app_pem_file" {
  key             = "GITHUB_APP_PEM_FILE"
  description     = "The contents of the secret of the GitHub App"
  value           = var.GITHUB_APP_PEM_FILE
  category        = "terraform"
  sensitive       = true
  variable_set_id = tfe_variable_set.github.id
}
