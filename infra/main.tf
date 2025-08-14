# -----------------------
# Red privada (VPC + Subred)
# -----------------------
resource "google_compute_network" "vpc" {
  name                    = "queplan-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "subnet" {
  name          = "queplan-subnet"
  ip_cidr_range = "10.10.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
  project       = var.project_id
}

# -----------------------
# Serverless VPC Connector
# -----------------------
resource "google_vpc_access_connector" "connector" {
  name          = "cr-connector"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.8.0.0/28"
  project       = var.project_id
}

# -----------------------
# Service Account para Backend
# -----------------------
resource "google_service_account" "backend_sa" {
  account_id   = "backend-sa"
  display_name = "Cloud Run Backend Service Account"
  project      = var.project_id
}

# -----------------------
# Secret Manager (DB password)
# -----------------------
resource "google_secret_manager_secret" "db_password_secret" {
  secret_id = "db-password"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "db_password_secret_version" {
  secret      = google_secret_manager_secret.db_password_secret.id
  secret_data = var.db_password
}

resource "google_secret_manager_secret_iam_member" "backend_secret_access" {
  secret_id = google_secret_manager_secret.db_password_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.backend_sa.email}"
}

# -----------------------
# AlloyDB Cluster + instancia
# -----------------------
resource "google_alloydb_cluster" "db_cluster" {
  cluster_id = "alloydb-cluster"
  project    = var.project_id
  location   = var.region
  network    = google_compute_network.vpc.id

  initial_user {
    user     = "postgres"
    password = var.db_password
  }
}

resource "google_alloydb_instance" "db_instance" {
  instance_id   = "alloydb-instance"
  cluster       = google_alloydb_cluster.db_cluster.id
  instance_type = "PRIMARY"

  database_flags = {
    cloudsql_iam_authentication = "on"
  }
}

# -----------------------
# IAM para invocar backend
# -----------------------
resource "google_project_iam_member" "backend_sa_run" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.backend_sa.email}"
}

# -----------------------
# Outputs
# -----------------------
output "alloydb_ip" {
  value = google_alloydb_instance.db_instance.ip_address[0]
}

output "alloydb_password_secret_name" {
  value = google_secret_manager_secret.db_password_secret.name
}

output "backend_sa_email" {
  value = google_service_account.backend_sa.email
}
