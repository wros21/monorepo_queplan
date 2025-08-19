# Cluster AlloyDB
resource "google_alloydb_cluster" "main" {
  cluster_id   = "${var.project_id}-alloydb-cluster"
  location     = var.region
  network      = google_compute_network.vpc.id

  initial_user {
    user     = var.db_user
    password = var.db_password
  }

  database_type = "POSTGRES"

  depends_on = [
    google_service_networking_connection.private_vpc_connection,
    google_project_service.apis
  ]
}

# Instancia primaria AlloyDB
resource "google_alloydb_instance" "primary" {
  cluster       = google_alloydb_cluster.main.name
  instance_id   = "${var.project_id}-primary-instance"
  instance_type = "PRIMARY"

  machine_config {
    cpu_count = 2
  }

  depends_on = [google_alloydb_cluster.main]
}

# Base de datos
resource "google_alloydb_database" "main_db" {
  cluster_id  = google_alloydb_cluster.main.cluster_id
  database_id = var.db_name

  depends_on = [google_alloydb_instance.primary]
}
