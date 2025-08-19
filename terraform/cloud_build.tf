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
    owner = "tu-usuario-github"  # Cambiar por tu usuario
    name  = "tu-repositorio"     # Cambiar por tu repositorio
    push {
      branch = "^main$"
    }
  }

  included_files = ["backend/**"]

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "build",
        "-t", "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/backend:$COMMIT_SHA",
        "-t", "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/backend:latest",
        "./backend"
      ]
    }

    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "push",
        "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/backend:$COMMIT_SHA"
      ]
    }

    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "push",
        "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/backend:latest"
      ]
    }

    step {
      name = "gcr.io/cloud-builders/gcloud"
      args = [
        "run", "deploy", "${var.project_id}-backend",
        "--image", "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/backend:$COMMIT_SHA",
        "--region", var.region,
        "--platform", "managed"
      ]
    }
  }

  depends_on = [google_project_service.apis]
}

# Cloud Build trigger para el frontend
resource "google_cloudbuild_trigger" "frontend_trigger" {
  name        = "${var.project_id}-frontend-trigger"
  description = "Trigger para construir y desplegar el frontend"

  github {
    owner = "tu-usuario-github"  # Cambiar por tu usuario
    name  = "tu-repositorio"     # Cambiar por tu repositorio
    push {
      branch = "^main$"
    }
  }

  included_files = ["frontend/**"]

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "build",
        "-t", "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/frontend:$COMMIT_SHA",
        "-t", "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/frontend:latest",
        "./frontend"
      ]
    }

    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "push",
        "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/frontend:$COMMIT_SHA"
      ]
    }

    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "push",
        "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/frontend:latest"
      ]
    }

    step {
      name = "gcr.io/cloud-builders/gcloud"
      args = [
        "run", "deploy", "${var.project_id}-frontend",
        "--image", "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/frontend:$COMMIT_SHA",
        "--region", var.region,
        "--platform", "managed"
      ]
    }
  }

  depends_on = [google_project_service.apis]
}
