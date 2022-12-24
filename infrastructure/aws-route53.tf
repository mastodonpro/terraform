### MX ###
resource "aws_route53_record" "mx" {
  zone_id = data.aws_route53_zone.zone.id
  name    = data.aws_route53_zone.zone.name
  type    = "MX"
  ttl     = "300"
  records = [
    "1 aspmx.l.google.com",
    "5 alt1.aspmx.l.google.com",
    "5 alt2.aspmx.l.google.com",
    "10 alt3.aspmx.l.google.com",
    "10 alt4.aspmx.l.google.com"
  ]
}

### TXT ###
resource "aws_route53_record" "txt" {
  zone_id = data.aws_route53_zone.zone.id
  name    = data.aws_route53_zone.zone.name
  type    = "TXT"
  ttl     = "3600"
  records = var.dns_maps[local.environment].txts
}
resource "aws_route53_record" "github" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "_github-challenge-mastodonpro-org"
  type    = "TXT"
  ttl     = "3600"
  records = [var.dns_maps[local.environment].github]
}
resource "aws_route53_record" "google-dkim" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "google._domainkey"
  type    = "TXT"
  ttl     = "3600"
  records = [var.dns_maps[local.environment].google-dkim]
}

### A ###
resource "aws_route53_record" "hubspot-a" {
  zone_id = data.aws_route53_zone.zone.id
  name    = data.aws_route53_zone.zone.name
  type    = "A"
  ttl     = "3600"
  records = var.dns_maps[local.environment].hubspot-a
}
