data "aws_route53_zone" "zone" {
  name = var.domain_map[local.environment]
}

resource "aws_default_subnet" "eu-west-1a" {
  availability_zone = "eu-west-1a"
}
resource "aws_default_subnet" "eu-west-1b" {
  availability_zone = "eu-west-1b"
}
resource "aws_default_subnet" "eu-west-1c" {
  availability_zone = "eu-west-1c"
}

resource "aws_default_vpc" "default" {}
resource "aws_default_security_group" "default" {
  vpc_id = aws_default_vpc.default.id
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
