data "aws_caller_identity" "current" {}

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

data "aws_internet_gateway" "eu-central-1" {
  provider = aws.eu-central-1
  filter {
    name   = "attachment.vpc-id"
    values = [aws_default_vpc.eu-central-1.id]
  }
}
resource "aws_default_route_table" "eu-central-1" {
  provider               = aws.eu-central-1
  default_route_table_id = aws_default_vpc.eu-central-1.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.eu-central-1.id
  }
}
