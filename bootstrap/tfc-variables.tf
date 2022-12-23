### VARIABLE SETS
# staging
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
# production
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
