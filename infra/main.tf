# Crear secreto en Secret Manager
resource "google_secret_manager_secret" "db_password_secret" {
  secret_id = "db-password"
  replication {
    automatic = true
  }
}

# Guardar la contraseña en el secreto
resource "google_secret_manager_secret_version" "db_password_secret_version" {
  secret      = google_secret_manager_secret.db_password_secret.id
  secret_data = var.db_password
}

# Dar permisos de lectura al backend de Cloud Run
resource "google_secret_manager_secret_iam_member" "backend_secret_access" {
  secret_id = google_secret_manager_secret.db_password_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.backend_service_account}"
}

# Crear AlloyDB Cluster
resource "google_alloydb_cluster" "db_cluster" {
  cluster_id   = "alloydb-cluster"
  project      = var.project_id
  location     = var.region
  network      = google_compute_network.default.id

  initial_user {
    user     = "postgres"
    password = var.db_password
  }
}

# Crear instancia principal de AlloyDB
resource "google_alloydb_instance" "db_instance" {
  instance_id    = "alloydb-instance"
  cluster        = google_alloydb_cluster.db_cluster.id
  instance_type  = "PRIMARY"

  database_flags = {
    cloudsql_iam_authentication = "on"
  }
}

# No mostramos la contraseña
output "alloydb_password_secret_name" {
  value = google_secret_manager_secret.db_password_secret.name
}
