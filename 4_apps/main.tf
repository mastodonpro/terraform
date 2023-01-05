data "tfe_outputs" "infrastructure" {
  organization = "mastodonpro"
  workspace    = "infrastructure-${local.environment}"
}
data "aws_route53_zone" "mpro" {
  name         = var.mpro_domain_map["${local.environment}"]
  private_zone = false
}

data "aws_kms_secrets" "eu-central-1" {
  provider = aws.eu-central-1
  secret {
    name    = "elasticsearch_master"
    payload = data.tfe_outputs.infrastructure.values.opensearch_encrypted_password.eu-central-1
  }
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
