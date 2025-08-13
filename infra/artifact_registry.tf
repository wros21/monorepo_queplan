resource "google_artifact_registry_repository" "app_repo" {
  location      = var.region
  repository_id = "app-repo"
  format        = "DOCKER"
  description   = "Repositorio de imagenes de monorepo"
}