# Service Account for Cloud Run Backend
resource "google_service_account" "backend_sa" {
  account_id   = "queplan-backend-sa"
  display_name = "Queplan Backend Service Account"
}

# Service Account for Cloud Run Frontend
resource "google_service_account" "frontend_sa" {
  account_id   = "queplan-frontend-sa"
  display_name = "Queplan Frontend Service Account"
}

# Service Account for Cloud Build
resource "google_service_account" "cloudbuild_sa" {
  account_id   = "queplan-cloudbuild-sa"
  display_name = "Queplan Cloud Build Service Account"
}

# IAM bindings for backend service account
resource "google_secret_manager_secret_iam_member" "backend_secret_access" {
  for_each = toset([
    google_secret_manager_secret.database_url.secret_id,
    data.google_secret_manager_secret.db_password.secret_id
  ])
  
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.backend_sa.email}"
}

resource "google_project_iam_member" "backend_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.backend_sa.email}"
}

# IAM bindings for Cloud Build service account
resource "google_project_iam_member" "cloudbuild_roles" {
  for_each = toset([
    "roles/run.admin",
    "roles/iam.serviceAccountUser",
    "roles/storage.admin",
    "roles/secretmanager.secretAccessor",
    "roles/artifactregistry.admin" // Agregado para Artifact Registry
  ])
  
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}
