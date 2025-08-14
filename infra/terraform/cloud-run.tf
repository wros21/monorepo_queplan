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
      image = "gcr.io/${var.project_id}/queplan-backend:latest"
      
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
        name  = "PORT"
        value = "8080"
      }
      
      env {
        name  = "ENVIRONMENT"
        value = var.environment
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
    google_vpc_access_connector.connector
  ]
}

# Frontend Cloud Run Service (Public)
resource "google_cloud_run_v2_service" "frontend" {
  name     = "queplan-frontend"
  location = var.region
  
  template {
    service_account = google_service_account.frontend_sa.email
    
    containers {
      image = "gcr.io/${var.project_id}/queplan-frontend:latest"
      
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
  
  depends_on = [google_project_service.apis]
}

# IAM policy for backend (private access only)
resource "google_cloud_run_service_iam_member" "backend_invoker" {
  service  = google_cloud_run_v2_service.backend.name
  location = google_cloud_run_v2_service.backend.location
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.frontend_sa.email}"
}

# IAM policy for frontend (public access)
resource "google_cloud_run_service_iam_member" "frontend_public" {
  service  = google_cloud_run_v2_service.frontend.name
  location = google_cloud_run_v2_service.frontend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
