output "frontend_url" {
  description = "URL of the frontend Cloud Run service"
  value       = google_cloud_run_v2_service.frontend.uri
}

output "backend_url" {
  description = "URL of the backend Cloud Run service"
  value       = google_cloud_run_v2_service.backend.uri
}

output "cloudsql_instance_name" {
  description = "CloudSQL instance name"
  value       = google_sql_database_instance.postgres.name
}

output "cloudsql_connection_name" {
  description = "CloudSQL connection name for backend"
  value       = google_sql_database_instance.postgres.connection_name
}

output "cloudsql_private_ip" {
  description = "CloudSQL private IP address"
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "vpc_connector_name" {
  description = "VPC Connector name"
  value       = google_vpc_access_connector.connector.name
}

output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "database_info" {
  description = "Database configuration"
  value = {
    instance_name = google_sql_database_instance.postgres.name
    database_name = google_sql_database.database.name
    user_name     = google_sql_user.user.name
  }
}
