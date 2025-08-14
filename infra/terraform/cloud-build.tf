# Cloud Build Trigger for main branch
resource "google_cloudbuild_trigger" "main_trigger" {
  name        = "queplan-main-trigger"
  description = "Trigger for main branch pushes"
  
  service_account = google_service_account.cloudbuild_sa.id
  
  github {
    owner = var.github_owner
    name  = var.github_repo
    push {
      branch = "^main$"
    }
  }
  
  filename = "cloudbuild.yaml"
  
  depends_on = [google_project_service.apis]
}

# Cloud Build Trigger for pull requests to main
resource "google_cloudbuild_trigger" "pr_trigger" {
  name        = "queplan-pr-trigger"
  description = "Trigger for pull requests to main"
  
  service_account = google_service_account.cloudbuild_sa.id
  
  github {
    owner = var.github_owner
    name  = var.github_repo
    pull_request {
      branch = "^main$"
    }
  }
  
  filename = "cloudbuild-pr.yaml"
  
  depends_on = [google_project_service.apis]
}
