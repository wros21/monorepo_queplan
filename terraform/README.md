# Infraestructura Terraform para Queplan

Este directorio contiene la configuración de Terraform para desplegar la aplicación Queplan en Google Cloud Platform.

## Arquitectura

- **Frontend**: Angular desplegado en Cloud Run
- **Backend**: Node.js/Express desplegado en Cloud Run
- **Base de datos**: AlloyDB PostgreSQL en red privada
- **Secretos**: Secret Manager para credenciales
- **CI/CD**: Cloud Build y Cloud Deploy
- **Redes**: VPC privada con VPC Connector

## Prerequisitos

1. Tener instalado Terraform >= 1.0
2. Tener instalado Google Cloud SDK
3. Autenticarse con GCP: `gcloud auth application-default login`
4. Habilitar la facturación en el proyecto GCP

## Despliegue

1. Copiar el archivo de variables:
   \`\`\`bash
   cp terraform.tfvars.example terraform.tfvars
   \`\`\`

2. Editar `terraform.tfvars` con tus valores específicos

3. Inicializar Terraform:
   \`\`\`bash
   terraform init
   \`\`\`

4. Planificar el despliegue:
   \`\`\`bash
   terraform plan
   \`\`\`

5. Aplicar la configuración:
   \`\`\`bash
   terraform apply
   \`\`\`

## Estructura de archivos

- `main.tf`: Configuración principal y providers
- `variables.tf`: Definición de variables
- `outputs.tf`: Outputs del despliegue
- `network.tf`: Configuración de redes VPC
- `secrets.tf`: Secret Manager y service accounts
- `alloydb.tf`: Configuración de AlloyDB
- `cloud_run.tf`: Servicios de Cloud Run
- `cloud_build.tf`: Configuración de CI/CD

## Acceso a la aplicación

Después del despliegue, las URLs de los servicios estarán disponibles en los outputs de Terraform:

\`\`\`bash
terraform output frontend_service_url
terraform output backend_service_url
\`\`\`

## Limpieza

Para destruir toda la infraestructura:

\`\`\`bash
terraform destroy
\`\`\`

**Nota**: Esto eliminará todos los recursos, incluyendo la base de datos. Asegúrate de hacer backup si es necesario.
