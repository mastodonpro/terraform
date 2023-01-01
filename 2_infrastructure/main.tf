data "aws_caller_identity" "current" {}

data "tfe_organization" "tfc" {
  name = "mastodonpro"
}
data "tfe_workspace" "apps" {
  name         = "app-${local.environment}"
  organization = "mastodonpro"
}

# https://github.com/aws/containers-roadmap/issues/474#issuecomment-1089845804
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles#role-arns-with-paths-removed
data "aws_iam_roles" "admin_sso_role" {
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
  name_regex  = "AWSReservedSSO_AdministratorAccess_.+"
}
locals {
  admin_sso_role_arn = [
    for parts in [for arn in data.aws_iam_roles.admin_sso_role.arns : split("/", arn)] :
    format("%s/%s", parts[0], element(parts, length(parts) - 1))
  ][0]
}

### NETWORKING ###
resource "aws_default_subnet" "eu-central-1a" {
  provider          = aws.eu-central-1
  availability_zone = "eu-central-1a"
}
resource "aws_default_subnet" "eu-central-1b" {
  provider          = aws.eu-central-1
  availability_zone = "eu-central-1b"
}
resource "aws_default_subnet" "eu-central-1c" {
  provider          = aws.eu-central-1
  availability_zone = "eu-central-1c"
}

resource "aws_default_vpc" "eu-central-1" {
  provider = aws.eu-central-1
}
resource "aws_default_security_group" "eu-central-1" {
  provider = aws.eu-central-1
  vpc_id   = aws_default_vpc.eu-central-1.id
  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
