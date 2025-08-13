variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "backend_service_account" {
  description = "Cuenta de servicio usada por el backend en Cloud Run"
  type        = string
}
