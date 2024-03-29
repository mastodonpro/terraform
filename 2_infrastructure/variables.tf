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
  default     = ""
}
variable "GITHUB_APP_INSTALLATION_ID" {
  type        = string
  description = "The Installation id of the GitHub App"
  default     = ""
}
variable "GITHUB_APP_PEM_FILE" {
  type        = string
  description = "The contents of the secret of the GitHub App"
  default     = ""
}

### DEFINE ENVIRONMENT SPECIFIC VARIABLES ###

# Mastodon pro
variable "mpro_domain_map" {
  type        = map(any)
  description = "Map of environment to domain."
  default = {
    staging    = "mastodon-st.com"
    production = "mastodonpro.com"
  }
}
variable "mpro_dns_maps" {
  type        = map(any)
  description = "Map of DNS records"
  default = {
    staging = {
      txts = [
        "google-site-verification=tfEqdf3Iw5LBCgODyE-CkvNLoGBw9Wh6pwNWJkG_ijE",
        "v=spf1 include:_spf.google.com include:amazonses.com ~all",
      ]
      github = "d904214b20"
      # watch out, the string needs to split in two pieces because of string length
      google-dkim = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAjvp2f82IvjNOIoatGtbYnwosEIJkZZC7ieq81aV+wCoNOgJIMaFRL+p5tO9WPz+SVbOYaOiBB7L2pOevIq0Tuc6uhdY5c5ju2FEuHwTPeUNza6lRzW8W8YIMtiD7J0MFCuVrRoq4EHnrXkDDJ8w318af7deowZf4ycuqBoV/sIHpzeT+jWWAhq\"\"fD8wa+/iyPnKZp4qAsZNiKoxsvDh08liETccP1JDrN8jrxuLZTfZkOh9ux2QWwgmV6v6cpJmB1Oqvg5ZzPvuvEtvDwRaVr9F+YjFDiwVZ/vWcZmwfi4UQhVrtt18F1nTkSSxyY32KrpU5GkTzWnt1VN16/T80OJQIDAQAB"
      hubspot-a   = ["199.60.103.15", "199.60.103.115"]
    }
    production = {
      txts = [
        "google-site-verification=BM3P8ekcrgp71ISlIj4xQhvIy1L87PP62cx_twU0qWg",
        "v=spf1 include:_spf.google.com include:amazonses.com include:spf.protection.outlook.com include:spf.mandrillapp.com ~all",
      ]
      github = "ce2921376d"
      # watch out, the string needs to split in two pieces because of string length
      google-dkim = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAgBWYv2+ZNEUasKNmL2oe2MqgtCJYB2mXDaInNk0dmQQC1lKMUAjb5J9DbCcKVoaNWrSGrG7gt0IbssJ2nig5k/5RP+/Y3FSmkBCfLmlCYFUNgH8CaKc87qv4JLBDMlCsu3Fc1PO8u/xMGoO20N10wfL+MV9irqi0U0Nb2C2U4lZnSOGjp0yBG6\"\"nUJkZPGQn2cz+R3FUhXbFCQioTnesbFP4OVEAWy3qdFG4W/J9ulJ218rWHymXXeQOZ8v5+504vwKiHifqS0cQQrqJuBTRgEB8B9aiC/EU2N40dg01MVxhjheCIRqOzxWYOSwGytMuEH8bDuZVJ7nnj+7xZTjh5bwIDAQAB"
      hubspot-a   = ["199.60.103.15", "199.60.103.115"]
    }
  }
}

# create the encrypted passwords without newline!
# aws kms --region eu-central-1 encrypt --key-id alias/sops --plaintext fileb://<(echo -n 'mypassword') --output text --query CiphertextBlob
variable "rds_instance_config" {
  type        = map(any)
  description = "Map of instance config for the RDS Postgres instance"
  default = {
    staging_eu-central-1 = {
      instance_class          = "db.t4g.micro" // ~12,60$ per month
      storage_type            = "gp2"          // ~8,13$ per month
      allocated_storage       = 64
      max_allocated_storage   = 256
      backup_retention_period = 1
      encrypted_root_password = "AQICAHgoCsPPrbUgWB1/8cZiYiOPdNBO9yeKtXazwq0Hqd5GUAFCbSnCcN+jtRdA5fwmI0+gAAAAcjBwBgkqhkiG9w0BBwagYzBhAgEAMFwGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQM9SIimLkuAw8fu4aRAgEQgC+0Y62ZuKuz76kFr5LvyLU9l3E1qsss7TFDcd8eXoyi0dLJz9sbegNy2ty1cPRPJg=="
    }
    production_eu-central-1 = {
      instance_class          = "db.t4g.large" // ~102.67$ per month
      storage_type            = "gp2"          // ~32.51$ per month
      allocated_storage       = 256
      max_allocated_storage   = 1024
      backup_retention_period = 7
      encrypted_root_password = "AQICAHhDzARqeGfai6RecH+rlMli7lmOvirZB75RQhTu6WEBKgFsYOS2qgaXzoEroxFqkdJJAAAAcjBwBgkqhkiG9w0BBwagYzBhAgEAMFwGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMKNgUj1qDQECRIjxCAgEQgC/lLTiMFrG/AyU5F89TdsdFMuRq/FRryB5JWQofmUG7tRLl8Rbsv6ttSaGcVq0BOA=="
    }
  }
}
variable "opensearch_config" {
  type        = map(any)
  description = "Map of config for the Opensearch cluster"
  default = {
    staging_eu-central-1 = {
      encrypted_master_password = "AQICAHgoCsPPrbUgWB1/8cZiYiOPdNBO9yeKtXazwq0Hqd5GUAFBiYtiKoPeaRQtqt8eiCBCAAAAcjBwBgkqhkiG9w0BBwagYzBhAgEAMFwGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQM+a5CUMN7aR0l9+sAAgEQgC8DwhDJxCbAVBRRHGc47HjDfQ1GtpOYo1hl8QqEXz+tuc5dI+OQrrYhZsVWXi5OwA=="
    }
    production_eu-central-1 = {
      encrypted_master_password = "AQICAHhDzARqeGfai6RecH+rlMli7lmOvirZB75RQhTu6WEBKgGbwYAeEJsIKt3KQFharrCsAAAAcjBwBgkqhkiG9w0BBwagYzBhAgEAMFwGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMUQkae9sGtE4od2maAgEQgC+zV0Bkyk2tav/HtXoO9jI5manaUSuzd/SmE33eZFghQaYYbM0h6d9KSSA11rxHlQ=="
    }
  }
}
