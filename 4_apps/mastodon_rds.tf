# RDS PostgreSQL database for mastodon
resource "postgresql_database" "mastodon" {
  provider = postgresql.aws_eu-central-1
  name     = "mastodon"
}
resource "postgresql_role" "mastodon" {
  provider = postgresql.aws_eu-central-1
  name     = "mastodon"
  login    = true
  password = data.aws_kms_secrets.eu-central-1.plaintext["postgres_mastodon"]
}

resource "postgresql_grant" "mastodon_schema_grant" {
  provider    = postgresql.aws_eu-central-1
  database    = postgresql_database.mastodon.name
  role        = postgresql_role.mastodon.name
  schema      = "public"
  object_type = "schema"
  privileges  = ["CREATE", "USAGE"]
}

resource "postgresql_grant" "mastodon_table_grant" {
  provider    = postgresql.aws_eu-central-1
  database    = postgresql_database.mastodon.name
  role        = postgresql_role.mastodon.name
  schema      = "public"
  object_type = "table"
  #  SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER, CREATE, CONNECT, TEMPORARY, EXECUTE, and USAGE
  privileges = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "TRIGGER"]
}
