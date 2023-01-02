# SSH
resource "tls_private_key" "flux_aws_eu-central-1" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

# Flux
locals {
  patches = {
    sops = <<-EOT
      apiVersion: v1
      kind: ServiceAccount
      metadata:
        name: kustomize-controller
        namespace: flux-system
        annotations:
          eks.amazonaws.com/role-arn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSKMSSopsIAMPolicy_eu-central-1
      EOT
  }
}

data "flux_install" "aws_eu-central-1" {
  target_path = "clusters/${local.environment}/aws_eu-central-1"
}
data "flux_sync" "aws_eu-central-1" {
  target_path = "clusters/${local.environment}/aws_eu-central-1"
  url         = "ssh://git@github.com/mastodonpro/${data.github_repository.flux.name}.git"
  branch      = "main"
  patch_names = keys(local.patches)
}

# Kubernetes
resource "kubernetes_namespace" "flux_system_aws_eu-central-1" {
  provider = kubernetes.aws_eu-central-1
  metadata {
    name = "flux-system"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
}

data "kubectl_file_documents" "flux_install_aws_eu-central-1" {
  provider = kubectl.aws_eu-central-1
  content  = data.flux_install.aws_eu-central-1.content
}
data "kubectl_file_documents" "flux_sync_aws_eu-central-1" {
  provider = kubectl.aws_eu-central-1
  content  = data.flux_sync.aws_eu-central-1.content
}

locals {
  flux_install_aws_eu-central-1 = [for v in data.kubectl_file_documents.flux_install_aws_eu-central-1.documents : {
    data : yamldecode(v)
    content : v
  }]
  flux_sync_aws_eu-central-1 = [for v in data.kubectl_file_documents.flux_sync_aws_eu-central-1.documents : {
    data : yamldecode(v)
    content : v
  }]
}

resource "kubectl_manifest" "flux_install_aws_eu-central-1" {
  provider   = kubectl.aws_eu-central-1
  for_each   = { for v in local.flux_install_aws_eu-central-1 : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system_aws_eu-central-1]
  yaml_body  = each.value
}
resource "kubectl_manifest" "flux_sync_aws_eu-central-1" {
  provider   = kubectl.aws_eu-central-1
  for_each   = { for v in local.flux_sync_aws_eu-central-1 : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system_aws_eu-central-1]
  yaml_body  = each.value
}

resource "kubernetes_secret" "flux_aws_eu-central-1" {
  provider   = kubernetes.aws_eu-central-1
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
resource "github_repository_deploy_key" "flux_aws_eu-central-1" {
  title      = "${local.environment}-cluster AWS eu-central-1"
  repository = data.github_repository.flux.name
  key        = tls_private_key.flux_aws_eu-central-1.public_key_openssh
  read_only  = true
}

resource "github_repository_file" "flux_install_aws_eu-central-1" {
  repository = data.github_repository.flux.name
  file       = data.flux_install.aws_eu-central-1.path
  content    = data.flux_install.aws_eu-central-1.content
}
resource "github_repository_file" "flux_sync_aws_eu-central-1" {
  repository = data.github_repository.flux.name
  file       = data.flux_sync.aws_eu-central-1.path
  content    = data.flux_sync.aws_eu-central-1.content
}
resource "github_repository_file" "flux_kustomize_aws_eu-central-1" {
  repository = data.github_repository.flux.name
  file       = data.flux_sync.aws_eu-central-1.kustomize_path
  content    = data.flux_sync.aws_eu-central-1.kustomize_content
}
resource "github_repository_file" "flux_patches_aws_eu-central-1" {
  #  `patch_file_paths` is a map keyed by the keys of `flux_sync.main`
  #  whose values are the paths where the patch files should be installed.
  for_each   = data.flux_sync.aws_eu-central-1.patch_file_paths
  repository = data.github_repository.flux.name
  file       = each.value
  content    = local.patches[each.key] # Get content of our patch files
}
