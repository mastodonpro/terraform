terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.2.3"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.14.0"
    }
  }
  cloud {
    organization = "mastodonpro"
    workspaces {
      tags = ["apps"]
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
provider "github" {
  owner = "mastodonpro"
  app_auth {
    id              = var.GITHUB_APP_ID
    installation_id = var.GITHUB_APP_INSTALLATION_ID
    pem_file        = var.GITHUB_APP_PEM_FILE
  }
}

provider "postgresql" {
  alias     = "aws_eu-central-1"
  host      = data.tfe_outputs.infrastructure.values.rds_address.eu-central-1
  password  = data.aws_kms_secrets.eu-central-1.plaintext["postgres_root"]
  superuser = false
}
