# RDS PostgreSQL database for mastodon
resource "postgresql_database" "mastodon" {
  provider = postgresql.aws_eu-central-1
  name     = "mastodon"
}
resource "postgresql_role" "mastodon" {
  name     = "mastodon"
  login    = true
  password = data.aws_kms_secrets.db_aws_eu-central-1.plaintext["mastodon"]
}

resource "postgresql_grant" "mastodon_schema_grant" {
  database    = postgresql_database.mastodon.name
  role        = postgresql_role.mastodon.name
  schema      = "public"
  object_type = "schema"
  privileges  = ["CREATE", "USAGE"]
}

resource "postgresql_grant" "mastodon_table_grant" {
  database    = postgresql_database.mastodon.name
  role        = postgresql_role.mastodon.name
  schema      = "public"
  object_type = "table"
  #  SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER, CREATE, CONNECT, TEMPORARY, EXECUTE, and USAGE
  privileges = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "TRIGGER"]
}

# Create SOPS encrypted secret
data "external" "sops_mastodon_db" {
  program     = ["/bin/bash", "sops.sh"]
  working_dir = "${path.module}/sops"
  query = {
    unencrypted = <<-EOT
      # Managed by Terraform ${var.ATLAS_WORKSPACE_NAME}
      apiVersion: v1
      kind: Secret
      metadata:
        name: db
        namespace: mastodon
      data:
        password: ${base64encode(data.aws_kms_secrets.db_aws_eu-central-1.plaintext["mastodon"])}
    EOT
  }
}
# Write encrypted secret file to GitHub
resource "github_repository_file" "fleet_infra_mastodon_secret_db" {
  repository          = "fleet-infra"
  file                = "apps/${local.environment}/eu-central-1/mastodon-secret-db.yaml"
  content             = "${data.external.sops_mastodon_db.result.encrypted}\n" # linter requires newline
  overwrite_on_create = true
  commit_author       = "Terraform - ${var.ATLAS_WORKSPACE_NAME}"
  commit_email        = "sysadmins+terraform@mastodonpro.com"
  commit_message      = "Update SOPS encrypted secret via Terraform"
}
