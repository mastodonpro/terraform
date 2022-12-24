output "mastodonpro_aws_route53_name_servers_staging" {
  value       = aws_route53_zone.staging.name_servers
  description = "The Name Servers of the Mastodon pro staging Route53 zone."
}
output "mastodonpro_aws_route53_name_servers_production" {
  value       = aws_route53_zone.production.name_servers
  description = "The Name Servers of the Mastodon pro production Route53 zone."
}
output "mastodonpro_aws_route53_name_servers_main" {
  value       = aws_route53_zone.main.name_servers
  description = "The Name Servers of the Mastodon pro main Route53 zone."
}
