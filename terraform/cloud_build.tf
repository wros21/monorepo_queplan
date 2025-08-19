# Artifact Registry para almacenar imágenes
resource "google_artifact_registry_repository" "main" {
  location      = var.region
  repository_id = "${var.project_id}-repo"
  description   = "Repositorio de imágenes Docker para ${var.project_id}"
  format        = "DOCKER"

  depends_on = [google_project_service.apis]
}

# Cloud Build trigger para el backend
resource "google_cloudbuild_trigger" "backend_trigger" {
  name        = "${var.project_id}-backend-trigger"
  description = "Trigger para construir y desplegar el backend"

  github {
    owner = var.github_owner
    name  = var.github_repo
    push {
      branch = "^main$"
    }
  }

  included_files = ["backend/**"]
  filename       = "backend/cloudbuild.yaml"

  depends_on = [google_project_service.apis]
}

# Cloud Build trigger para el frontend
resource "google_cloudbuild_trigger" "frontend_trigger" {
  name        = "${var.project_id}-frontend-trigger"
  description = "Trigger para construir y desplegar el frontend"

  github {
    owner = var.github_owner
    name  = var.github_repo
    push {
      branch = "^main$"
    }
  }

  included_files = ["frontend/**"]
  filename       = "frontend/cloudbuild.yaml"

  depends_on = [google_project_service.apis]
}
