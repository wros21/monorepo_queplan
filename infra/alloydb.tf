# Módulo oficial de AlloyDB (cluster + primary instance)
module "alloydb" {
  source  = "GoogleCloudPlatform/alloy-db/google"
  version = "~> 0.5"

  project_id                    = var.project_id
  region                        = var.region

  # Cluster principal
  cluster_id                    = var.alloydb_cluster_id
  network                       = "projects/${var.project_id}/global/networks/default"
  automated_backup_policy       = true
  continuous_backup_enabled     = true

  # Instancia primaria
  primary_instance_id           = var.alloydb_instance_id
  primary_instance_machine_type = "db-custom-2-7680" # ajusta tamaño

  # Nodo(s) de lectura opcionales (0 = ninguno)
  read_pool_instance_count      = 0
}

# Secret con credenciales de app (usuario/clave y endpoint privado)
resource "google_secret_manager_secret" "db_credentials" {
  secret_id  = "db-credentials"
  replication { automatic = true }
}

resource "google_secret_manager_secret_version" "db_credentials_version" {
  secret = google_secret_manager_secret.db_credentials.id
  # Nota: el host privado es la IP de la instancia primaria
  secret_data = jsonencode({
    user     = var.db_user
    password = var.db_password
    dbname   = var.db_name
    host     = module.alloydb.primary_instance_ip_address
    port     = 5432
    sslmode  = "disable"
  })
}
