terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    tfe = {
      version = "~> 0.38.0"
    }
  }
  cloud {
    organization = "mastodonpro"
    workspaces {
      tags = ["bootstrap"]
    }
  }
}
provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Provider    = "terraform"
      TFWorkspace = var.ATLAS_WORKSPACE_NAME
    }
  }
}
