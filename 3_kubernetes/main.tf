data "tfe_outputs" "infrastructure" {
  organization = "mastodonpro"
  workspace    = "infrastructure-${local.environment}"
}
data "github_repository" "flux" {
  name = "fleet-infra"
}
