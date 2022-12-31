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

variable "rds_instance_config" {
  type        = map(any)
  description = "Map of instance config for the RDS Postgres instance"
  default = {
    staging_eu-central-1 = {
      instance_class              = "db.t4g.micro" // ~12,60$ per month
      storage_type                = "gp2"          // ~8,13$ per month
      allocated_storage           = 64
      max_allocated_storage       = 256
      backup_retention_period     = 7
      encrypted_root_password     = "AQICAHgoCsPPrbUgWB1/8cZiYiOPdNBO9yeKtXazwq0Hqd5GUAECCL9Rp1VGSED7y7JiRyg6AAAAczBxBgkqhkiG9w0BBwagZDBiAgEAMF0GCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQM1RlcMhGIxp7oPd/QAgEQgDB/UA6u5nrhhbA2lxkhJoOszRKF2vof6iiBQ/e9Gkn+JKVD0/+DltLLcFNTdg7REe8="
      mastodon_encrypted_password = "AQICAHgoCsPPrbUgWB1/8cZiYiOPdNBO9yeKtXazwq0Hqd5GUAGdcCUkEaBrvCBIav5PRw6eAAAAczBxBgkqhkiG9w0BBwagZDBiAgEAMF0GCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMWQLGvaolA5pqRMx+AgEQgDBewAO6P3Hxm6pFTlwf6+xv35098gHJafx/MxRWK5ZnvTWJ7fEJzmNT3jN6gsdvhBc="
    }
    production_eu-central-1 = {
      instance_class              = "db.t4g.large" // ~102.67$ per month
      storage_type                = "gp2"          // ~32.51$ per month
      allocated_storage           = 256
      max_allocated_storage       = 1024
      backup_retention_period     = 1
      encrypted_root_password     = "AQICAHhDzARqeGfai6RecH+rlMli7lmOvirZB75RQhTu6WEBKgGNL6jcWo2Uzp+CTSiC8jSGAAAAczBxBgkqhkiG9w0BBwagZDBiAgEAMF0GCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMuxG1Bw6aCsFxJ5yRAgEQgDCcKc0GbEcslp4dRtTM85bqk4M6D+YcldzOY0Z6evM5attdzeF9eT7u97UdgeJ6HPU="
      mastodon_encrypted_password = "AQICAHhDzARqeGfai6RecH+rlMli7lmOvirZB75RQhTu6WEBKgE5T5dZa6WKJW3c7M+k6rT/AAAAczBxBgkqhkiG9w0BBwagZDBiAgEAMF0GCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQM4aQ2JTEuYrn2EkNjAgEQgDAqieq0Pu89PprXvaSkjKWTl7wEadfOTFwrSxib60B1COl26/wYjTCDVgez7hx6wEA="
    }
  }
}
