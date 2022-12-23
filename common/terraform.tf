terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  cloud {
    organization = "mastodonpro"
    workspaces {
      tags = ["common"]
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
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
  default_tags {
    tags = {
      Provider    = "terraform"
      TFWorkspace = var.ATLAS_WORKSPACE_NAME
    }
  }
}
