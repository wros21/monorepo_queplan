# Reference existing secret
data "google_secret_manager_secret" "db_password" {
  secret_id = "db-password"
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
  secret_data = "postgresql://${var.db_user}:${data.google_secret_manager_secret_version.db_password.secret_data}@${google_sql_database_instance.postgres.private_ip_address}:5432/${var.db_name}"
  
  depends_on = [google_sql_database_instance.postgres]
}
