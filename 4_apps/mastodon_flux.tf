# Write configmap to GitHub
resource "github_repository_file" "fleet_infra_mastodon_values_aws" {
  repository          = "fleet-infra"
  file                = "apps/${local.environment}/aws_eu-central-1/mastodon-values-aws.yaml"
  content             = <<-EOT
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: mastodon
      namespace: mastodon
    spec:
      values:
        elasticsearch:
          host: ${data.tfe_outputs.infrastructure.values.opensearch_address.eu-central-1}
        postgresql:
          postgresqlHostname: ${data.tfe_outputs.infrastructure.values.rds_address.eu-central-1}
        redis:
          hostname: ${data.tfe_outputs.infrastructure.values.redis_address.eu-central-1}
  EOT
  overwrite_on_create = true
  commit_author       = "Terraform - ${var.ATLAS_WORKSPACE_NAME}"
  commit_email        = "sysadmins+terraform@mastodonpro.com"
  commit_message      = "Update HelmRelease values"
}

# Create SOPS encrypted secret
data "external" "sops_mastodon_aws" {
  program     = ["/bin/bash", "sops.sh"]
  working_dir = "${path.module}/sops"
  query = {
    kms_arn     = data.tfe_outputs.infrastructure.values.kms_arn_sops.eu-central-1
    unencrypted = <<-EOT
      # Managed by Terraform ${var.ATLAS_WORKSPACE_NAME}
      ---
      apiVersion: v1
      kind: Secret
      metadata:
        name: postgres
        namespace: mastodon
      data:
        password: ${base64encode(data.aws_kms_secrets.eu-central-1.plaintext["postgres_mastodon"])}
      EOT
    /* not used unless mastodon supports TLS connections
      ---
      apiVersion: v1
      kind: Secret
      metadata:
        name: redis
        namespace: mastodon
      data:
        redis-password: ${base64encode(data.aws_kms_secrets.eu-central-1.plaintext["redis_mastodon"])}
    */
  }
}
# Write encrypted secret file to GitHub
resource "github_repository_file" "fleet_infra_mastodon_secret_aws" {
  repository          = "fleet-infra"
  file                = "apps/${local.environment}/aws_eu-central-1/mastodon-secret-aws.yaml"
  content             = "${data.external.sops_mastodon_aws.result.encrypted}\n" # linter requires newline
  overwrite_on_create = true
  commit_author       = "Terraform - ${var.ATLAS_WORKSPACE_NAME}"
  commit_email        = "sysadmins+terraform@mastodonpro.com"
  commit_message      = "Update SOPS encrypted Secret"
}
