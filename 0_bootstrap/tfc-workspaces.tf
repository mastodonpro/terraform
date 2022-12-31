### WORKSPACES

### common workspace ###
resource "tfe_workspace" "common" {
  name                = "common"
  tag_names           = ["common"]
  auto_apply          = false
  description         = "Common Workspace"
  working_directory   = "1_common"
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
resource "tfe_workspace_variable_set" "github_common" {
  variable_set_id = tfe_variable_set.github.id
  workspace_id    = tfe_workspace.common.id
}

### infrastructure- workspaces ###
resource "tfe_workspace" "infrastructure_staging" {
  name              = "infrastructure-staging"
  tag_names         = ["infrastructure"]
  auto_apply        = true
  description       = "Infrastructure Workspace - staging"
  working_directory = "2_infrastructure"
  vcs_repo {
    identifier     = "mastodonpro/terraform"
    oauth_token_id = var.TFC_OAUTH_TOKEN_ID
  }
  organization = data.tfe_organization.mastodonpro.name
}
resource "tfe_workspace" "infrastructure_production" {
  name              = "infrastructure-production"
  tag_names         = ["infrastructure"]
  auto_apply        = false
  description       = "Infrastructure Workspace - production"
  working_directory = "2_infrastructure"
  vcs_repo {
    identifier     = "mastodonpro/terraform"
    oauth_token_id = var.TFC_OAUTH_TOKEN_ID
  }
  organization = data.tfe_organization.mastodonpro.name
}
# AWS env vars
resource "tfe_workspace_variable_set" "aws_infrastructure_staging" {
  variable_set_id = tfe_variable_set.aws_staging.id
  workspace_id    = tfe_workspace.infrastructure_staging.id
}
resource "tfe_workspace_variable_set" "aws_infrastructure_production" {
  variable_set_id = tfe_variable_set.aws_production.id
  workspace_id    = tfe_workspace.infrastructure_production.id
}
# GitHub terraform vars
resource "tfe_workspace_variable_set" "github_infrastructure_staging" {
  variable_set_id = tfe_variable_set.github.id
  workspace_id    = tfe_workspace.infrastructure_staging.id
}
resource "tfe_workspace_variable_set" "github_infrastructure_production" {
  variable_set_id = tfe_variable_set.github.id
  workspace_id    = tfe_workspace.infrastructure_production.id
}

### kubernetes- workspaces ###
resource "tfe_workspace" "kubernetes_staging" {
  name              = "kubernetes-staging"
  tag_names         = ["kubernetes"]
  auto_apply        = true
  description       = "kubernetes Workspace - staging"
  working_directory = "3_kubernetes"
  vcs_repo {
    identifier     = "mastodonpro/terraform"
    oauth_token_id = var.TFC_OAUTH_TOKEN_ID
  }
  organization = data.tfe_organization.mastodonpro.name
}
resource "tfe_workspace" "kubernetes_production" {
  name              = "kubernetes-production"
  tag_names         = ["kubernetes"]
  auto_apply        = false
  description       = "kubernetes Workspace - production"
  working_directory = "3_kubernetes"
  vcs_repo {
    identifier     = "mastodonpro/terraform"
    oauth_token_id = var.TFC_OAUTH_TOKEN_ID
  }
  organization = data.tfe_organization.mastodonpro.name
}
# AWS env vars
resource "tfe_workspace_variable_set" "aws_kubernetes_staging" {
  variable_set_id = tfe_variable_set.aws_staging.id
  workspace_id    = tfe_workspace.kubernetes_staging.id
}
resource "tfe_workspace_variable_set" "aws_kubernetes_production" {
  variable_set_id = tfe_variable_set.aws_production.id
  workspace_id    = tfe_workspace.kubernetes_production.id
}
# GitHub terraform vars
resource "tfe_workspace_variable_set" "github_kubernetes_staging" {
  variable_set_id = tfe_variable_set.github.id
  workspace_id    = tfe_workspace.kubernetes_staging.id
}
resource "tfe_workspace_variable_set" "github_kubernetes_production" {
  variable_set_id = tfe_variable_set.github.id
  workspace_id    = tfe_workspace.kubernetes_production.id
}
# Terraform Cloud variable
resource "tfe_variable" "kubernetes_tfe_token_staging" {
  key          = "TFE_TOKEN"
  description  = "Terrform Cloud Token"
  value        = var.TFE_TOKEN
  category     = "env"
  sensitive    = true
  workspace_id = tfe_workspace.kubernetes_staging.id
}
resource "tfe_variable" "kubernetes_tfe_token_production" {
  key          = "TFE_TOKEN"
  description  = "Terrform Cloud Token"
  value        = var.TFE_TOKEN
  category     = "env"
  sensitive    = true
  workspace_id = tfe_workspace.kubernetes_production.id
}

### apps- workspaces ###
resource "tfe_workspace" "apps_staging" {
  name              = "apps-staging"
  tag_names         = ["apps"]
  auto_apply        = true
  description       = "apps Workspace - staging"
  working_directory = "4_apps"
  vcs_repo {
    identifier     = "mastodonpro/terraform"
    oauth_token_id = var.TFC_OAUTH_TOKEN_ID
  }
  organization = data.tfe_organization.mastodonpro.name
}
resource "tfe_workspace" "apps_production" {
  name              = "apps-production"
  tag_names         = ["apps"]
  auto_apply        = false
  description       = "apps Workspace - production"
  working_directory = "4_apps"
  vcs_repo {
    identifier     = "mastodonpro/terraform"
    oauth_token_id = var.TFC_OAUTH_TOKEN_ID
  }
  organization = data.tfe_organization.mastodonpro.name
}
# AWS env vars
resource "tfe_workspace_variable_set" "aws_apps_staging" {
  variable_set_id = tfe_variable_set.aws_staging.id
  workspace_id    = tfe_workspace.apps_staging.id
}
resource "tfe_workspace_variable_set" "aws_apps_production" {
  variable_set_id = tfe_variable_set.aws_production.id
  workspace_id    = tfe_workspace.apps_production.id
}
# GitHub terraform vars
resource "tfe_workspace_variable_set" "github_apps_staging" {
  variable_set_id = tfe_variable_set.github.id
  workspace_id    = tfe_workspace.apps_staging.id
}
resource "tfe_workspace_variable_set" "github_apps_production" {
  variable_set_id = tfe_variable_set.github.id
  workspace_id    = tfe_workspace.apps_production.id
}
# Terraform Cloud variable
resource "tfe_variable" "apps_tfe_token_staging" {
  key          = "TFE_TOKEN"
  description  = "Terrform Cloud Token"
  value        = var.TFE_TOKEN
  category     = "env"
  sensitive    = true
  workspace_id = tfe_workspace.apps_staging.id
}
resource "tfe_variable" "apps_tfe_token_production" {
  key          = "TFE_TOKEN"
  description  = "Terrform Cloud Token"
  value        = var.TFE_TOKEN
  category     = "env"
  sensitive    = true
  workspace_id = tfe_workspace.apps_production.id
}
