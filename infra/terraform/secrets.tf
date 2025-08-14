# Reference existing secret with the correct name
data "google_secret_manager_secret" "db_password" {
  secret_id = "db-credentials" // Cambiado a db-credentials como mencionaste
}

data "google_secret_manager_secret_version" "db_password" {
  secret = data.google_secret_manager_secret.db_password.id
}

# Create database URL secret for applications
resource "google_secret_manager_secret" "database_url" {
  secret_id = "database-url"
  
  replication {
    auto {}
  }
  
  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret_version" "database_url" {
  secret = google_secret_manager_secret.database_url.id
  secret_data = "postgresql://${var.db_user}:vbv6kax0ktc@${google_sql_database_instance.postgres.private_ip_address}:5432/${var.db_name}"
  
  depends_on = [google_sql_database_instance.postgres]
}

# IAM permissions for accessing secrets
resource "google_secret_manager_secret_iam_member" "backend_database_url_access" {
  secret_id = google_secret_manager_secret.database_url.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.backend_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "backend_db_credentials_access" {
  secret_id = data.google_secret_manager_secret.db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.backend_sa.email}"
}
