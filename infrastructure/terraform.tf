terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  cloud {
    organization = "treely"
    workspaces {
      tags = ["infrastructure"]
    }
  }
}
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
