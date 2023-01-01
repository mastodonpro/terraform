data "tfe_outputs" "infrastructure" {
  organization = "mastodonpro"
  workspace    = "infrastructure-${local.environment}"
}
data "aws_kms_secrets" "db_aws_eu-central-1" {
  provider = aws.eu-central-1
  secret {
    name    = "root"
    payload = data.tfe_outputs.infrastructure.values.rds_encrypted_password.eu-central-1
  }
  secret {
    name    = "mastodon"
    payload = var.db_encrypted_passwords["${local.environment}_eu-central-1"].mastodon
  }
}
