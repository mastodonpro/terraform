output "eks_eu-central-1_cluster_endpoint" {
  description = "Endpoint for EKS control plane in Zone eu-central-1"
  value       = module.eks_eu-central-1.cluster_endpoint
}
output "eks_eu-central-1_cluster_certificate_authority_data" {
  description = "Certificate Authority Data for EKS control plane in Zone eu-central-1"
  value       = module.eks_eu-central-1.cluster_certificate_authority_data
}
output "eks_eu-central-1_cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane in Zone eu-central-1"
  value       = module.eks_eu-central-1.cluster_security_group_id
}
output "eks_eu-central-1_cluster_name" {
  description = "Kubernetes Cluster Name in Zone eu-central-1"
  value       = module.eks_eu-central-1.cluster_name
}

output "mastodonpro_aws_route53_name_servers" {
  value       = aws_route53_zone.mpro.name_servers
  description = "The Name Servers of the Mastodon pro Route53 zone."
}
