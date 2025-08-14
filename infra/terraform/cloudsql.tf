# Cloud SQL PostgreSQL Instance (Private)
resource "google_sql_database_instance" "postgres" {
  name             = "queplan-postgres"
  database_version = "POSTGRES_15"
  region           = var.region
  deletion_protection = false

  settings {
    tier = "db-f1-micro"
    
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.vpc.id
      enable_private_path_for_google_cloud_services = true
    }
    
    backup_configuration {
      enabled = true
      start_time = "03:00"
    }
    
    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }
  }

  depends_on = [
    google_service_networking_connection.private_vpc_connection,
    google_project_service.apis
  ]
}

# Database
resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres.name
}

# Database User
resource "google_sql_user" "user" {
  name     = var.db_user
  instance = google_sql_database_instance.postgres.name
  password = data.google_secret_manager_secret_version.db_password.secret_data
}
