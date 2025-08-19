output "vpc_network_name" {
  description = "Nombre de la red VPC"
  value       = google_compute_network.vpc.name
}

output "private_subnet_name" {
  description = "Nombre de la subred privada"
  value       = google_compute_subnetwork.private_subnet.name
}

output "alloydb_cluster_name" {
  description = "Nombre del cluster AlloyDB"
  value       = google_alloydb_cluster.main.name
}

output "alloydb_instance_ip" {
  description = "IP privada de la instancia AlloyDB"
  value       = google_alloydb_instance.primary.ip_address
}

output "backend_service_url" {
  description = "URL del servicio backend en Cloud Run"
  value       = google_cloud_run_service.backend.status[0].url
}

output "frontend_service_url" {
  description = "URL del servicio frontend en Cloud Run"
  value       = google_cloud_run_service.frontend.status[0].url
}

output "secret_manager_db_password_id" {
  description = "ID del secreto de la contraseña de BD en Secret Manager"
  value       = google_secret_manager_secret.db_password.secret_id
}
