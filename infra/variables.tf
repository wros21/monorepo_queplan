variable "project_id" { default = "queplan-468417" }
variable "region"     { default = "us-central1" }

# AlloyDB
variable "alloydb_cluster_id"  { default = "queplan-cluster" }
variable "alloydb_instance_id" { default = "primary-us-central1" }
variable "db_name"             { default = "retoqueplan" }
variable "db_user"             { default = "psqladm" }
variable "db_password"         {"vbv6kax0ktc"}

# GitHub Trigger
variable "github_owner" { default = "wros21" }
variable "github_repo"  { default = "monorepo_queplan" }
