### SSL CERTIFICATES ###
resource "aws_acm_certificate" "mastodon" {
  provider          = aws.eu-central-1
  domain_name       = "social.${data.aws_route53_zone.mpro.name}"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_route53_record" "mastodon_domain_validation" {
  for_each = {
    for dvo in aws_acm_certificate.mastodon.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.mpro.zone_id
}
