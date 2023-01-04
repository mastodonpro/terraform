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
  description = "The Name Servers of the Mastodon pro Route53 zone."
  value       = aws_route53_zone.mpro.name_servers
}

output "kms_arn_sops" {
  description = "The ARN of the SOPS KMS key"
  value = {
    eu-central-1 = aws_kms_key.sops_eu-central-1.arn
  }
}

output "rds_address" {
  description = "The address of the RDS instance"
  value = {
    eu-central-1 = aws_db_instance.rds_eu-central-1.address
  }
}
output "rds_encrypted_password" {
  description = "The encrypted password for the RDS root user"
  value = {
    eu-central-1 = var.rds_instance_config["${local.environment}_eu-central-1"].encrypted_root_password
  }
  sensitive = true
}

output "redis_address" {
  description = "The address of the Elasticache instance"
  value = {
    eu-central-1 = aws_elasticache_replication_group.redis_eu-central-1.primary_endpoint_address
  }
}
