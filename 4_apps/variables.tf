### DETERMINE ENVIRONMENT ###
variable "ATLAS_WORKSPACE_NAME" {
  # https://support.hashicorp.com/hc/en-us/articles/360022827893-Terraform-workspace-value-is-always-default
  type = string
}
// determine the environment based on the workspace name
locals {
  environment = regex("-(production|staging)$", var.ATLAS_WORKSPACE_NAME)[0]
}
# GitHub (populated via variable sets defined in bootstrap)
variable "GITHUB_APP_ID" {
  type        = string
  description = "The id of the GitHub App"
}
variable "GITHUB_APP_INSTALLATION_ID" {
  type        = string
  description = "The Installation id of the GitHub App"
}
variable "GITHUB_APP_PEM_FILE" {
  type        = string
  description = "The contents of the secret of the GitHub App"
}

### DEFINE ENVIRONMENT SPECIFIC VARIABLES ###
variable "mpro_domain_map" {
  type        = map(any)
  description = "Map of environment to domain."
  default = {
    staging    = "mastodon-st.com"
    production = "mastodonpro.com"
  }
}

# create the encrypted passwords without newline!
# aws kms --region eu-central-1 encrypt --key-id alias/sops --plaintext fileb://<(echo -n 'mypassword') --output text --query CiphertextBlob
variable "encrypted_passwords" {
  type        = map(any)
  description = "Map of instance config for the RDS Postgres instance"
  default = {
    staging_eu-central-1 = {
      postgres_mastodon = "AQICAHgoCsPPrbUgWB1/8cZiYiOPdNBO9yeKtXazwq0Hqd5GUAGCSt9UT4yfYXuozTVYpaCGAAAAcjBwBgkqhkiG9w0BBwagYzBhAgEAMFwGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMhJnB1kuDIP+lsI2XAgEQgC8V1ys06HmZqBc+A3Y656mZrzHdGmBVDJ3bqHvRge+w0DQ0Z53BGMRQdjBBQ2+nrQ=="
      redis_mastodon    = "AQICAHgoCsPPrbUgWB1/8cZiYiOPdNBO9yeKtXazwq0Hqd5GUAHwflIbIg1XKZ/iK5aLM50MAAAAcjBwBgkqhkiG9w0BBwagYzBhAgEAMFwGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQM+jutfXxq7A7+jh8AAgEQgC+FKLiQWT6vrSiWDQlK+dDB7fm2zlgCz5pmViMbeLixtDwGcNxZZjpmzjPnriT7Lg=="
    }
    production_eu-central-1 = {
      postgres_mastodon = "AQICAHhDzARqeGfai6RecH+rlMli7lmOvirZB75RQhTu6WEBKgEWA2/belPpFwry8Mx7Ub/lAAAAcjBwBgkqhkiG9w0BBwagYzBhAgEAMFwGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMlH6nhrhw0DbFuKWfAgEQgC91I52eQDtO8iCpMd8T/dRAd2DmWgG9D5YJgSAw0pWvBMgnUO4bGYoY+ahbnJwh/A=="
      redis_mastodon    = "AQICAHhDzARqeGfai6RecH+rlMli7lmOvirZB75RQhTu6WEBKgHixgY8mXA38UmAZjp0EyAUAAAAcjBwBgkqhkiG9w0BBwagYzBhAgEAMFwGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMpnEB5TKQPOQErrC9AgEQgC/W7nYZylZSXDmjo3x9VqwxnJC3DVY36dWG+cfu/TFPZ/9wYJTEP63unGD1UpV4fQ=="
    }
  }
}
