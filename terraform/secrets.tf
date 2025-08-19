# Secret Manager para la contraseña de la base de datos
resource "google_secret_manager_secret" "db_password" {
  secret_id = "${var.project_id}-db-password"
  
  replication {
    auto {}
  }

  depends_on = [google_project_service.apis]
}

# Versión del secreto con la contraseña
resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.db_password
}

# IAM para que Cloud Run pueda acceder al secreto
resource "google_secret_manager_secret_iam_member" "backend_secret_access" {
  secret_id = google_secret_manager_secret.db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.backend_sa.email}"
}

# Service Account para el backend
resource "google_service_account" "backend_sa" {
  account_id   = "${var.project_id}-backend-sa"
  display_name = "Service Account para Backend"
  description  = "Service Account usado por el backend para acceder a recursos de GCP"
}

# Service Account para el frontend
resource "google_service_account" "frontend_sa" {
  account_id   = "${var.project_id}-frontend-sa"
  display_name = "Service Account para Frontend"
  description  = "Service Account usado por el frontend"
}
