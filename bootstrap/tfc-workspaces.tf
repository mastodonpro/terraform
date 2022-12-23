### WORKSPACES
# common workspace
resource "tfe_workspace" "common" {
  name                = "common"
  auto_apply          = false
  description         = "Common Workspace"
  working_directory   = "common"
  global_remote_state = true
  vcs_repo {
    identifier     = "mastodonpro/terraform"
    oauth_token_id = var.TFC_OAUTH_TOKEN_ID
  }
  organization = data.tfe_organization.mastodonpro.name
}
resource "tfe_workspace_variable_set" "aws_common" {
  variable_set_id = tfe_variable_set.aws_production.id
  workspace_id    = tfe_workspace.common.id
}

# infrastructure- workspaces
resource "tfe_workspace" "infrastructure_staging" {
  name              = "infrastructure-staging"
  auto_apply        = true
  description       = "Infrastructure Workspace - staging"
  working_directory = "infrastructure"
  vcs_repo {
    identifier     = "mastodonpro/terraform"
    oauth_token_id = var.TFC_OAUTH_TOKEN_ID
  }
  organization = data.tfe_organization.mastodonpro.name
}
resource "tfe_workspace" "infrastructure_production" {
  name              = "infrastructure-production"
  auto_apply        = false
  description       = "Infrastructure Workspace - production"
  working_directory = "infrastructure"
  vcs_repo {
    identifier     = "mastodonpro/terraform"
    oauth_token_id = var.TFC_OAUTH_TOKEN_ID
  }
  organization = data.tfe_organization.mastodonpro.name
}

resource "tfe_workspace_variable_set" "aws_infrastructure_staging" {
  variable_set_id = tfe_variable_set.aws_staging.id
  workspace_id    = tfe_workspace.infrastructure_staging.id
}
resource "tfe_workspace_variable_set" "aws_infrastructure_production" {
  variable_set_id = tfe_variable_set.aws_production.id
  workspace_id    = tfe_workspace.infrastructure_production.id
}
