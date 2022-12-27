resource "aws_route53_zone" "join" {
  # only create when running on production
  count = local.environment == "production" ? 1 : 0
  name  = "pro.joinmastodon.org"
}
