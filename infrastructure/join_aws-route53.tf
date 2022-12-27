resource "aws_route53_zone" "main" {
  # only create when running on production
  count = local.environment == "production" ? 1 : 0
  name  = "pro.joinmastodon.org"
}
