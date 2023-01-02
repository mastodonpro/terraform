resource "aws_elasticache_user" "mastodon" {
  user_id       = "mastodon"
  user_name     = "mastodon"
  access_string = "on ~mastodon::* +@all"
  engine        = "REDIS"
  passwords     = [data.aws_kms_secrets.eu-central-1.plaintext["redis_mastodon"]]
}

# Write configmap to GitHub
resource "github_repository_file" "fleet_infra_mastodon_values_redis" {
  repository          = "fleet-infra"
  file                = "apps/${local.environment}/aws_eu-central-1/mastodon-values-redis.yaml"
  content             = <<-EOT
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: mastodon
      namespace: mastodon
    spec:
      values:
        redis:
          hostname: ${data.tfe_outputs.infrastructure.values.redis_address.eu-central-1}
  EOT
  overwrite_on_create = true
  commit_author       = "Terraform - ${var.ATLAS_WORKSPACE_NAME}"
  commit_email        = "sysadmins+terraform@mastodonpro.com"
  commit_message      = "Update HelmRelease values via Terraform"
}
# Create SOPS encrypted secret
data "external" "sops_mastodon_redis" {
  program     = ["/bin/bash", "sops.sh"]
  working_dir = "${path.module}/sops"
  query = {
    kms_arn     = data.tfe_outputs.infrastructure.values.kms_arn_sops.eu-central-1
    unencrypted = <<-EOT
      # Managed by Terraform ${var.ATLAS_WORKSPACE_NAME}
      apiVersion: v1
      kind: Secret
      metadata:
        name: redis
        namespace: mastodon
      data:
        redis-password: ${base64encode(data.aws_kms_secrets.eu-central-1.plaintext["redis_mastodon"])}
    EOT
  }
}
# Write encrypted secret file to GitHub
resource "github_repository_file" "fleet_infra_mastodon_secret_redis" {
  repository          = "fleet-infra"
  file                = "apps/${local.environment}/aws_eu-central-1/mastodon-secret-redis.yaml"
  content             = "${data.external.sops_mastodon_redis.result.encrypted}\n" # linter requires newline
  overwrite_on_create = true
  commit_author       = "Terraform - ${var.ATLAS_WORKSPACE_NAME}"
  commit_email        = "sysadmins+terraform@mastodonpro.com"
  commit_message      = "Update SOPS encrypted Secret via Terraform"
}
