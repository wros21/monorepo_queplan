# AlloyDB Cluster
resource "google_alloydb_cluster" "primary" {
  cluster_id   = "queplan-cluster"
  location     = var.region
  network      = google_compute_network.vpc.id
  
  initial_user {
    user     = var.db_user
    password = data.google_secret_manager_secret_version.db_password.secret_data
  }

  database_type = "POSTGRES"

  depends_on = [
    google_service_networking_connection.private_vpc_connection,
    google_project_service.apis
  ]
}

# AlloyDB Primary Instance
resource "google_alloydb_instance" "primary" {
  cluster       = google_alloydb_cluster.primary.name
  instance_id   = "queplan-primary-instance"
  instance_type = "PRIMARY"

  machine_config {
    cpu_count = 2
  }

  depends_on = [google_alloydb_cluster.primary]
}

# Database
resource "google_alloydb_database" "database" {
  cluster_id  = google_alloydb_cluster.primary.cluster_id
  database_id = var.db_name
  
  depends_on = [google_alloydb_instance.primary]
}
