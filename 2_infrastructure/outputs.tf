output "eks_eu-central-1" {
  description = "Cluster data for EKS cluster in eu-central-1"
  value = {
    cluster_endpoint          = module.eks_eu-central-1.cluster_endpoint
    cluster_name              = module.eks_eu-central-1.cluster_name
    cluster_security_group_id = module.eks_eu-central-1.cluster_security_group_id
  }
}
output "eks_eu-central-1_sensitive" {
  description = "Sensitive cluster data for EKS cluster in eu-central-1"
  value = {
    cluster_certificate_authority_data = module.eks_eu-central-1.cluster_certificate_authority_data
  }
  sensitive = true
}

output "mastodonpro_aws_route53_name_servers" {
  value       = aws_route53_zone.mpro.name_servers
  description = "The Name Servers of the Mastodon pro Route53 zone."
}
