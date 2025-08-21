variable "project_id" {
  description = "ID del proyecto de GCP"
  type        = string
  default     = "queplan-469422"
}

variable "region" {
  description = "Región de GCP"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zona de GCP"
  type        = string
  default     = "us-central1-a"
}

variable "environment" {
  description = "Entorno de despliegue"
  type        = string
  default     = "desarrollo"
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "retoqueplan1"
}

variable "db_user" {
  description = "Usuario de la base de datos"
  type        = string
  default     = "psqladm"
}

variable "db_password" {
  description = "Contraseña de la base de datos"
  type        = string
  default     = "Vbv6kax0ktc!"
  sensitive   = true
}

variable "backend_image" {
  description = "Imagen del backend en Container Registry"
  type        = string
  default     = "gcr.io/queplan/backend:latest"
}

variable "frontend_image" {
  description = "Imagen del frontend en Container Registry"
  type        = string
  default     = "gcr.io/queplan/frontend:latest"
}

variable "github_owner" {
  description = "Propietario del repositorio GitHub"
  type        = string
  default     = "wros21"  
}

variable "github_repo" {
  description = "Nombre del repositorio GitHub"
  type        = string
  default     = "https://github.com/wros21/monorepo_queplan"     
}
