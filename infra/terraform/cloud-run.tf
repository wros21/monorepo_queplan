# Backend Cloud Run Service (Private)
resource "google_cloud_run_v2_service" "backend" {
  name     = "queplan-backend"
  location = var.region
  
  template {
    service_account = google_service_account.backend_sa.email
    
    vpc_access {
      connector = google_vpc_access_connector.connector.id
      egress    = "PRIVATE_RANGES_ONLY"
    }
    
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/queplan-repo/backend:latest"
      
      ports {
        container_port = 8080
      }
      
      env {
        name = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.database_url.secret_id
            version = "latest"
          }
        }
      }
      
      env {
        name = "DB_HOST"
        value = google_sql_database_instance.postgres.private_ip_address
      }
      
      env {
        name = "DB_USER"
        value = var.db_user
      }
      
      env {
        name = "DB_NAME"
        value = var.db_name
      }
      
      env {
        name = "DB_PORT"
        value = "5432"
      }
      
      env {
        name  = "PORT"
        value = "8080"
      }
      
      env {
        name  = "NODE_ENV"
        value = "production"
      }
      
      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }
    }
    
    scaling {
      min_instance_count = 0
      max_instance_count = 10
    }
  }
  
  depends_on = [
    google_project_service.apis,
    google_vpc_access_connector.connector,
    google_secret_manager_secret_version.database_url
  ]
}

# Frontend Cloud Run Service (Public)
resource "google_cloud_run_v2_service" "frontend" {
  name     = "queplan-frontend"
  location = var.region
  
  template {
    service_account = google_service_account.frontend_sa.email
    
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/queplan-repo/frontend:latest"
      
      ports {
        container_port = 3000
      }
      
      env {
        name  = "NEXT_PUBLIC_API_URL"
        value = google_cloud_run_v2_service.backend.uri
      }
      
      env {
        name  = "PORT"
        value = "3000"
      }
      
      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }
    }
    
    scaling {
      min_instance_count = 0
      max_instance_count = 10
    }
  }
  
  depends_on = [
    google_project_service.apis,
    google_cloud_run_v2_service.backend
  ]
}

resource "google_cloud_run_service_iam_member" "backend_invoker" {
  service  = google_cloud_run_v2_service.backend.name
  location = google_cloud_run_v2_service.backend.location
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.frontend_sa.email}"
}

# Frontend público
resource "google_cloud_run_service_iam_member" "frontend_public" {
  service  = google_cloud_run_v2_service.frontend.name
  location = google_cloud_run_v2_service.frontend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
