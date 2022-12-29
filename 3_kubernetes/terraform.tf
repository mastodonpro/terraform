terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">= 0.0.13"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
  cloud {
    organization = "mastodonpro"
    workspaces {
      tags = ["kubernetes"]
    }
  }
}
# default provider
provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Provider    = "terraform"
      Workspace   = var.ATLAS_WORKSPACE_NAME
      Environment = local.environment
    }
  }
}
provider "aws" {
  alias  = "eu-central-1"
  region = "eu-central-1"
  default_tags {
    tags = {
      Provider    = "terraform"
      Workspace   = var.ATLAS_WORKSPACE_NAME
      Environment = local.environment
    }
  }
}
provider "aws" {
  alias  = "eu-central-2"
  region = "eu-central-2"
  default_tags {
    tags = {
      Provider    = "terraform"
      Workspace   = var.ATLAS_WORKSPACE_NAME
      Environment = local.environment
    }
  }
}
provider "flux" {}
provider "github" {
  owner = "mastodonpro"
  app_auth {
    id              = var.GITHUB_APP_ID
    installation_id = var.GITHUB_APP_INSTALLATION_ID
    pem_file        = var.GITHUB_APP_PEM_FILE
  }
}
provider "kubectl" {
  alias                  = "aws_eu-central-1"
  host                   = module.eks_eu-central-1.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_eu-central-1.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.tfe_outputs.infrastructure.values.eks_eu-central-1_cluster_name]
  }
}
provider "kubernetes" {
  alias                  = "aws_eu-central-1"
  host                   = module.eks_eu-central-1.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_eu-central-1.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.tfe_outputs.infrastructure.values.eks_eu-central-1_cluster_name]
  }
}
