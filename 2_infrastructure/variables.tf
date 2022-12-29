### DETERMINE ENVIRONMENT ###
variable "ATLAS_WORKSPACE_NAME" {
  # https://support.hashicorp.com/hc/en-us/articles/360022827893-Terraform-workspace-value-is-always-default
  type = string
}
// determine the environment based on the workspace name
locals {
  environment = regex("-(production|staging)$", var.ATLAS_WORKSPACE_NAME)[0]
  #workspace_name = regex("\\d_(.+)-(staging|production)$", var.ATLAS_WORKSPACE_NAME)[0]
  workspace_name = "infrastructure"
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
