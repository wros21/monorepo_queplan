# Artifact Registry Repository
resource "google_artifact_registry_repository" "app_repo" {
  location      = var.region
  repository_id = "app-repo"
  description   = "Repository for Queplan application images"
  format        = "DOCKER"

  depends_on = [google_project_service.apis]
}
