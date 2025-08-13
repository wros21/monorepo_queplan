# Trigger para backend (build + deploy al push a main|develop)
resource "google_cloudbuild_trigger" "backend" {
  name    = "backend-ci"
  project = var.project_id

  github {
    owner = var.github_owner
    name  = var.github_repo
    push {
      branch = "^(main|develop)$"
    }
  }

  included_files = ["backend/**"]
  filename       = "backend/cloudbuild.yaml"
}

# Trigger para frontend
resource "google_cloudbuild_trigger" "frontend" {
  name    = "frontend-ci"
  project = var.project_id

  github {
    owner = var.github_owner
    name  = var.github_repo
    push {
      branch = "^(main|develop)$"
    }
  }

  included_files = ["frontend/**"]
  filename       = "frontend/cloudbuild.yaml"
}
