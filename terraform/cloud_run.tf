# Cloud Run service para el backend
resource "google_cloud_run_service" "backend" {
  name     = "${var.project_id}-backend"
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.backend_sa.email
      
      containers {
        image = var.backend_image
        
        ports {
          container_port = 3000
        }

        env {
          name  = "NODE_ENV"
          value = "production"
        }

        env {
          name  = "PORT"
          value = "3000"
        }

        env {
          name  = "DB_HOST"
          value = google_alloydb_instance.primary.ip_address
        }

        env {
          name  = "DB_PORT"
          value = "5432"
        }

        env {
          name  = "DB_NAME"
          value = var.db_name
        }

        env {
          name  = "DB_USER"
          value = var.db_user
        }

        env {
          name = "DB_PASSWORD"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.db_password.secret_id
              key  = "latest"
            }
          }
        }

        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"        = "10"
        "autoscaling.knative.dev/minScale"        = "1"
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.id
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_project_service.apis,
    google_alloydb_instance.primary,
    google_vpc_access_connector.connector
  ]
}

# Cloud Run service para el frontend
resource "google_cloud_run_service" "frontend" {
  name     = "${var.project_id}-frontend"
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.frontend_sa.email
      
      containers {
        image = var.frontend_image
        
        ports {
          container_port = 80
        }

        env {
          name  = "API_URL"
          value = "${google_cloud_run_service.backend.status[0].url}/api"
        }

        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "10"
        "autoscaling.knative.dev/minScale" = "1"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_project_service.apis,
    google_cloud_run_service.backend
  ]
}

# IAM para permitir acceso público a los servicios
resource "google_cloud_run_service_iam_member" "backend_public" {
  service  = google_cloud_run_service.backend.name
  location = google_cloud_run_service.backend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_service_iam_member" "frontend_public" {
  service  = google_cloud_run_service.frontend.name
  location = google_cloud_run_service.frontend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
