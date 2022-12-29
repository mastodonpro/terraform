terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.8.0" # https://pullanswer.com/questions/maint-public-repositories-do-not-play-well-with-advanced-security-settings
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

provider "github" {
  owner = "mastodonpro"
  app_auth {
    id              = var.GITHUB_APP_ID
    installation_id = var.GITHUB_APP_INSTALLATION_ID
    pem_file        = var.GITHUB_APP_PEM_FILE
  }
}
