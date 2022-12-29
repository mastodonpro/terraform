### ROUTE53 ###
resource "aws_route53_zone" "mpro" {
  name = var.mpro_domain_map[local.environment]
}

### MX ###
resource "aws_route53_record" "mpro_mx" {
  zone_id = aws_route53_zone.mpro.id
  name    = aws_route53_zone.mpro.name
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
resource "aws_route53_record" "mpro_txt" {
  zone_id = aws_route53_zone.mpro.id
  name    = aws_route53_zone.mpro.name
  type    = "TXT"
  ttl     = "3600"
  records = var.mpro_dns_maps[local.environment].txts
}
resource "aws_route53_record" "mpro_github" {
  zone_id = aws_route53_zone.mpro.id
  name    = "_github-challenge-mastodonpro-org"
  type    = "TXT"
  ttl     = "3600"
  records = [var.mpro_dns_maps[local.environment].github]
}
resource "aws_route53_record" "mpro_google-dkim" {
  zone_id = aws_route53_zone.mpro.id
  name    = "google._domainkey"
  type    = "TXT"
  ttl     = "3600"
  records = [var.mpro_dns_maps[local.environment].google-dkim]
}

### A ###
resource "aws_route53_record" "mpro_hubspot-a" {
  zone_id = aws_route53_zone.mpro.id
  name    = aws_route53_zone.mpro.name
  type    = "A"
  ttl     = "3600"
  records = var.mpro_dns_maps[local.environment].hubspot-a
}
