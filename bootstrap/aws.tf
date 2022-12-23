### SSO ###
data "aws_ssoadmin_instances" "instance" {}
resource "aws_ssoadmin_permission_set" "admin_access" {
  name             = "AdministratorAccess"
  description      = "Access for Administrators"
  instance_arn     = tolist(data.aws_ssoadmin_instances.instance.arns)[0]
  session_duration = "PT12H"
}
resource "aws_identitystore_group" "sysadmins" {
  display_name      = "Sysadmins"
  description       = "System Administrators"
  identity_store_id = tolist(data.aws_ssoadmin_instances.instance.identity_store_ids)[0]
}
resource "aws_ssoadmin_account_assignment" "sysadmins_assignment" {
  instance_arn       = aws_ssoadmin_permission_set.admin_access.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn
  principal_id       = aws_identitystore_group.sysadmins.group_id
  principal_type     = "GROUP"
  target_id          = aws_organizations_account.account.id
  target_type        = "AWS_ACCOUNT"
}

### ORGANIZATIONS ###
resource "aws_organizations_account" "account_staging" {
  name      = "mastodonpro-staging"
  email     = "sysadmins+staging@mastodonpro.com"
  role_name = "OrganizationAccountAccessRole"
  # There is no AWS Organizations API for reading role_name
  lifecycle {
    ignore_changes = [role_name]
  }
}
resource "aws_organizations_account" "account_production" {
  name      = "mastodonpro-production"
  email     = "sysadmins+production@mastodonpro.com"
  role_name = "OrganizationAccountAccessRole"
  # There is no AWS Organizations API for reading role_name
  lifecycle {
    ignore_changes = [role_name]
  }
}

# Create aliased provider to manage the account above
provider "aws" {
  alias  = "environment_staging"
  region = "eu-west-1"
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.account_staging.id}:role/OrganizationAccountAccessRole"
  }
  default_tags {
    tags = {
      Provider    = "terraform"
      TFWorkspace = var.ATLAS_WORKSPACE_NAME
    }
  }
}
provider "aws" {
  alias  = "environment_production"
  region = "eu-west-1"
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.account_production.id}:role/OrganizationAccountAccessRole"
  }
  default_tags {
    tags = {
      Provider    = "terraform"
      TFWorkspace = var.ATLAS_WORKSPACE_NAME
    }
  }
}

### IAM group ###
resource "aws_iam_group" "terraform_staging" {
  provider = aws.environment_staging
  name     = "terraform"
}
resource "aws_iam_group_policy_attachment" "terraform_staging" {
  provider   = aws.environment_staging
  group      = aws_iam_group.terraform_staging.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group" "terraform_production" {
  provider = aws.environment_production
  name     = "terraform"
}
resource "aws_iam_group_policy_attachment" "terraform_production" {
  provider   = aws.environment_production
  group      = aws_iam_group.terraform_production.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

### IAM user ###
resource "aws_iam_user" "terraform_staging" {
  provider = aws.environment_staging
  name     = "terraform"
}
resource "aws_iam_user_group_membership" "terraform_staging" {
  provider = aws.environment_staging
  user     = aws_iam_user.terraform_staging.name
  groups = [
    aws_iam_group.terraform_staging.name,
  ]
}
resource "aws_iam_user" "terraform_production" {
  provider = aws.environment_production
  name     = "terraform"
}
resource "aws_iam_user_group_membership" "terraform_production" {
  provider = aws.environment_production
  user     = aws_iam_user.terraform_production.name
  groups = [
    aws_iam_group.terraform_production.name,
  ]
}

### IAM access key ###
# Be careful when it comes to key rotation
# This can be problem in terraform, make sure to read the docs
resource "aws_iam_access_key" "terraform_staging" {
  provider = aws.environment_staging
  user     = aws_iam_user.terraform_staging.name
}
resource "aws_iam_access_key" "terraform_production" {
  provider = aws.environment_production
  user     = aws_iam_user.terraform_production.name
}

### ROUTE53 ###
resource "aws_route53_zone" "zone_staging" {
  provider = aws.environment_staging
  name     = var.domain_map["staging"]
}
resource "aws_route53_zone" "zone_production" {
  provider = aws.environment_production
  name     = var.domain_map["production"]
}
