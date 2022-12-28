resource "github_repository" "flux" {
  name       = "fleet-infra"
  visibility = "public"
  auto_init  = true
}
