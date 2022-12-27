terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
  }
  cloud {
    organization = "mastodonpro"
    workspaces {
      tags = ["infrastructure"]
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
provider "kubernetes" {
  alias                  = "aws_eu-central-1"
  host                   = module.eks_eu-central-1.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_eu-central-1.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_eu-central-1.cluster_name]
  }
}
