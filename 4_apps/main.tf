data "tfe_outputs" "infrastructure" {
  organization = "mastodonpro"
  workspace    = "infrastructure-${local.environment}"
}
data "aws_kms_secrets" "eu-central-1" {
  provider = aws.eu-central-1
  secret {
    name    = "postgres_root"
    payload = data.tfe_outputs.infrastructure.values.rds_encrypted_password.eu-central-1
  }
  secret {
    name    = "postgres_mastodon"
    payload = var.encrypted_passwords["${local.environment}_eu-central-1"].postgres_mastodon
  }
  secret {
    name    = "redis_mastodon"
    payload = var.encrypted_passwords["${local.environment}_eu-central-1"].redis_mastodon
  }
}
