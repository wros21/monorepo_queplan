# Copia este archivo a terraform.tfvars y ajusta los valores

project_id = "queplan-469422"
region     = "us-central1"
zone       = "us-central1-a"
environment = "desarrollo"

github_owner = "wros21"
github_repo  = "monorepo_queplan"
github_token = "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"

# Configuración de base de datos
db_name     = "retoqueplan1"
db_user     = "postgres"
db_password = "Vbv6kax0ktc!"

# Imágenes Docker (se actualizarán automáticamente con Cloud Build)
backend_image  = "us-central1-docker.pkg.dev/queplan-469422/queplan-repo/backend:latest"
frontend_image = "us-central1-docker.pkg.dev/queplan-469422/queplan-repo/frontend:latest"
