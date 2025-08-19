# Copia este archivo a terraform.tfvars y ajusta los valores

project_id = "queplan"
region     = "us-central1"
zone       = "us-central1-a"
environment = "desarrollo"

# Configuración de base de datos
db_name     = "retoqueplan"
db_user     = "psqladm"
db_password = "Vbv6kax0ktc!"

# Imágenes Docker (se actualizarán automáticamente con Cloud Build)
backend_image  = "us-central1-docker.pkg.dev/queplan/queplan-repo/backend:latest"
frontend_image = "us-central1-docker.pkg.dev/queplan/queplan-repo/frontend:latest"
