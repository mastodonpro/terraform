output "mastodonpro_aws_route53_name_servers_staging" {
  value       = aws_route53_zone.zone_staging.name_servers
  description = "The Name Servers of the Mastodon pro staging Route53 zone."
}
output "mastodonpro_aws_route53_name_servers_production" {
  value       = aws_route53_zone.zone_production.name_servers
  description = "The Name Servers of the Mastodon pro production Route53 zone."
}
