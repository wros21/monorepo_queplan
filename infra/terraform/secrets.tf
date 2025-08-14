# Reference existing secret with the correct name
data "google_secret_manager_secret" "db_credentials" {
  secret_id = "db-credentials"
}

data "google_secret_manager_secret_version" "db_credentials" {
  secret = data.google_secret_manager_secret.db_credentials.id
}

# Create database URL secret for applications (usando el secreto existente)
resource "google_secret_manager_secret" "database_url" {
  secret_id = "database-url"
  
  replication {
    auto {}
  }
  
  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret_version" "database_url" {
  secret = google_secret_manager_secret.database_url.id
  secret_data = "postgresql://${var.db_user}:${var.db_password}@${google_sql_database_instance.postgres.private_ip_address}:5432/${var.db_name}"
  
  depends_on = [
    google_sql_database_instance.postgres
  ]
}

# IAM permissions for accessing secrets
resource "google_secret_manager_secret_iam_member" "backend_database_url_access" {
  secret_id = google_secret_manager_secret.database_url.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.backend_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "backend_db_credentials_access" {
  secret_id = data.google_secret_manager_secret.db_credentials.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.backend_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "cloudbuild_database_url_access" {
  secret_id = google_secret_manager_secret.database_url.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_secret_manager_secret_iam_member" "cloudbuild_db_credentials_access" {
  secret_id = data.google_secret_manager_secret.db_credentials.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}
