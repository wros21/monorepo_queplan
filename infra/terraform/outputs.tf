output "frontend_url" {
  description = "URL of the frontend Cloud Run service"
  value       = google_cloud_run_v2_service.frontend.uri
}

output "backend_url" {
  description = "URL of the backend Cloud Run service"
  value       = google_cloud_run_v2_service.backend.uri
}

output "alloydb_cluster_name" {
  description = "AlloyDB cluster name"
  value       = google_alloydb_cluster.primary.name
}

output "vpc_connector_name" {
  description = "VPC Connector name"
  value       = google_vpc_access_connector.connector.name
}

output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}
