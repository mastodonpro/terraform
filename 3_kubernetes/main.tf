data "aws_caller_identity" "current" {}

data "tfe_outputs" "infrastructure" {
  organization = "mastodonpro"
  workspace    = "infrastructure-${local.environment}"
}
data "github_repository" "flux" {
  name = "fleet-infra"
}
locals {
  github_known_hosts = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
}
