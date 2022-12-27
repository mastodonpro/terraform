output "eks_eu-central-1_cluster_endpoint" {
  description = "Endpoint for EKS control plane in Zone eu-central-1"
  value       = module.eks_eu-central-1.cluster_endpoint
}

output "eks_eu-central-1_cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane in Zone eu-central-1"
  value       = module.eks_eu-central-1.cluster_security_group_id
}

output "eks_eu-central-1_cluster_name" {
  description = "Kubernetes Cluster Name in Zone eu-central-1"
  value       = module.eks_eu-central-1.cluster_name
}
