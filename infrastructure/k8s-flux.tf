# SSH
resource "tls_private_key" "flux_aws_eu-central-1" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

# Flux
data "flux_install" "aws_eu-central-1" {
  target_path = "clusters/${local.environment}/aws_eu-central-1"
}
data "flux_sync" "aws_eu-central-1" {
  target_path = "clusters/${local.environment}/aws_eu-central-1"
  url         = "ssh://git@github.com/mastodonpro/${data.github_repository.flux.name}.git"
  branch      = "main"
}

# Kubernetes
resource "kubernetes_namespace" "flux_system_aws_eu-central-1" {
  metadata {
    name = "flux-system"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
}

data "kubectl_file_documents" "install_aws_eu-central-1" {
  content = data.flux_install.aws_eu-central-1.content
}
data "kubectl_file_documents" "sync_aws_eu-central-1" {
  content = data.flux_sync.aws_eu-central-1.content
}

locals {
  install_aws_eu-central-1 = [for v in data.kubectl_file_documents.install_aws_eu-central-1.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
  sync_aws_eu-central-1 = [for v in data.kubectl_file_documents.sync_aws_eu-central-1.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
}

resource "kubectl_manifest" "flux_install_aws_eu-central-1" {
  for_each   = { for v in local.install_aws_eu-central-1 : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system_aws_eu-central-1]
  yaml_body  = each.value
}
resource "kubectl_manifest" "flux_sync_aws_eu-central-1" {
  for_each   = { for v in local.sync_aws_eu-central-1 : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system_aws_eu-central-1]
  yaml_body  = each.value
}

resource "kubernetes_secret" "flux_aws_eu-central-1" {
  depends_on = [kubectl_manifest.flux_install_aws_eu-central-1]
  metadata {
    name      = data.flux_sync.aws_eu-central-1.secret
    namespace = data.flux_sync.aws_eu-central-1.namespace
  }
  data = {
    identity       = tls_private_key.flux_aws_eu-central-1.private_key_pem
    "identity.pub" = tls_private_key.flux_aws_eu-central-1.public_key_pem
    known_hosts    = local.github_known_hosts
  }
}

# GitHub
data "github_repository" "flux" {
  name = "fleet-infra"
}
resource "github_repository_deploy_key" "flux_aws_eu-central-1" {
  title      = "${local.environment}-cluster AWS eu-central-1"
  repository = data.github_repository.flux.name
  key        = tls_private_key.flux_aws_eu-central-1.public_key_openssh
  read_only  = true
}

resource "github_repository_file" "install_aws_eu-central-1" {
  repository = data.github_repository.flux.name
  file       = data.flux_install.aws_eu-central-1.path
  content    = data.flux_install.aws_eu-central-1.content
}
resource "github_repository_file" "sync_aws_eu-central-1" {
  repository = github_repository.flux.name
  file       = data.flux_sync.aws_eu-central-1.path
  content    = data.flux_sync.aws_eu-central-1.content
}
resource "github_repository_file" "kustomize" {
  repository = github_repository.flux.name
  file       = data.flux_sync.aws_eu-central-1.kustomize_path
  content    = data.flux_sync.aws_eu-central-1.kustomize_content
}
