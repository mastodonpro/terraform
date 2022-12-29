resource "github_repository" "flux" {
  name       = "fleet-infra"
  visibility = "public"
  auto_init  = true
  security_and_analysis {
    advanced_security {
      status = "enabled"
    }
    secret_scanning {
      status = "enabled"
    }
    secret_scanning_push_protection {
      status = "enabled"
    }
  }
}
