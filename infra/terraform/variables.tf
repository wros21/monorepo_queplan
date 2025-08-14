variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "queplan-468417"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "monorepo_queplan"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "retoqueplan"
}

variable "db_user" {
  description = "Database user"
  type        = string
  default     = "psqladm"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}
