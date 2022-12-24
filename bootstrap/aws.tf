### ORGANIZATIONS ###
resource "aws_organizations_account" "staging" {
  name      = "mastodonpro-staging"
  email     = "sysadmins+staging@mastodonpro.com"
  role_name = "OrganizationAccountAccessRole"
  # There is no AWS Organizations API for reading role_name
  lifecycle {
    ignore_changes = [role_name]
  }
}
resource "aws_organizations_account" "production" {
  name      = "mastodonpro-production"
  email     = "sysadmins+production@mastodonpro.com"
  role_name = "OrganizationAccountAccessRole"
  # There is no AWS Organizations API for reading role_name
  lifecycle {
    ignore_changes = [role_name]
  }
}

# Create aliased providers to manage the account above
provider "aws" {
  alias  = "staging"
  region = "eu-west-1"
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.staging.id}:role/OrganizationAccountAccessRole"
  }
  default_tags {
    tags = {
      Provider    = "terraform"
      TFWorkspace = var.ATLAS_WORKSPACE_NAME
    }
  }
}
provider "aws" {
  alias  = "production"
  region = "eu-west-1"
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.production.id}:role/OrganizationAccountAccessRole"
  }
  default_tags {
    tags = {
      Provider    = "terraform"
      TFWorkspace = var.ATLAS_WORKSPACE_NAME
    }
  }
}

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
resource "aws_ssoadmin_account_assignment" "sysadmins_staging" {
  instance_arn       = aws_ssoadmin_permission_set.admin_access.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn
  principal_id       = aws_identitystore_group.sysadmins.group_id
  principal_type     = "GROUP"
  target_id          = aws_organizations_account.staging.id
  target_type        = "AWS_ACCOUNT"
}
resource "aws_ssoadmin_account_assignment" "sysadmins_production" {
  instance_arn       = aws_ssoadmin_permission_set.admin_access.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn
  principal_id       = aws_identitystore_group.sysadmins.group_id
  principal_type     = "GROUP"
  target_id          = aws_organizations_account.production.id
  target_type        = "AWS_ACCOUNT"
}


### IAM users ###
resource "aws_iam_user" "terraform_staging" {
  provider = aws.staging
  name     = "terraform"
}
resource "aws_iam_user" "terraform_production" {
  provider = aws.production
  name     = "terraform"
}

### IAM groups ###
resource "aws_iam_group" "terraform_staging" {
  provider = aws.staging
  name     = "terraform"
}
resource "aws_iam_group_policy_attachment" "terraform_staging" {
  provider   = aws.staging
  group      = aws_iam_group.terraform_staging.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group" "terraform_production" {
  provider = aws.production
  name     = "terraform"
}
resource "aws_iam_group_policy_attachment" "terraform_production" {
  provider   = aws.production
  group      = aws_iam_group.terraform_production.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

### IAM group memberships ###
resource "aws_iam_user_group_membership" "terraform_staging" {
  provider = aws.staging
  user     = aws_iam_user.terraform_staging.name
  groups = [
    aws_iam_group.terraform_staging.name,
  ]
}
resource "aws_iam_user_group_membership" "terraform_production" {
  provider = aws.production
  user     = aws_iam_user.terraform_production.name
  groups = [
    aws_iam_group.terraform_production.name,
  ]
}

### IAM access keys ###
# Be careful when it comes to key rotation
# This can be problem in terraform, make sure to read the docs
resource "aws_iam_access_key" "terraform_staging" {
  provider = aws.staging
  user     = aws_iam_user.terraform_staging.name
}
resource "aws_iam_access_key" "terraform_production" {
  provider = aws.production
  user     = aws_iam_user.terraform_production.name
}

### ROUTE53 ###
resource "aws_route53_zone" "staging" {
  provider = aws.staging
  name     = var.domain_map["staging"]
}
resource "aws_route53_zone" "production" {
  provider = aws.production
  name     = var.domain_map["production"]
}
resource "aws_route53_zone" "main" {
  provider = aws.production
  name     = "pro.joinmastodon.org"
}
