output "artifact_registry_repo" {
  value = google_artifact_registry_repository.app_repo.repository_id
}

output "vpc_connector_name" {
  value = google_vpc_access_connector.serverless_conn.name
}

output "alloydb_primary_ip" {
  value = module.alloydb.primary_instance_ip_address
}
