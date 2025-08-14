📌 Descripción del Proyecto

Este proyecto consta de dos aplicaciones:

    🖥️ Frontend: Aplicación en React, que sirve contenido estático y debe ser pública para pruebas.

    🔧 Backend: API en Node.js (Express), que proporciona servicios a la interfaz.

Ambas aplicaciones son dockerizadas y desplegadas en Cloud Run de Google Cloud Platform (GCP).
☁️ Requisitos Previos

    Cuenta en GCP con un proyecto habilitado.

    Facturación activa en GCP.

    GCP CLI instalado y autenticado (gcloud init).

    Docker instalado.

    Permisos para usar Cloud Run, Cloud Build y Artifact Registry.

🛠️ Servicios de GCP Utilizados
Servicio	Propósito
Cloud Run	Ejecución de contenedores sin servidor
Cloud Build	Construcción de imágenes desde código fuente
Artifact Registry	Almacenamiento de imágenes Docker
IAM	Control de permisos
Secret Manager	(Opcional) Gestión de variables sensibles
Cloud Logging	Monitoreo de logs
🚀 Pasos para la Implementación
1. Clonar el repositorio


git clone https://github.com/wros21/monorepo_queplan.git

cd proyecto

2. Crear el proyecto en GCP

gcloud projects create queplan
gcloud config set project queplan

3. Activar APIs necesarias - Conectar a Cloud shell y ejecutar

gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com

4. Crear el repositorio en Artifact Registry

gcloud artifacts repositories create docker-repo \
  --repository-format=docker \
  --location=us-central1

📦 Dockerizar las Aplicaciones
Frontend (React)

Dockerfile

FROM node:18-alpine AS build
WORKDIR /app
COPY . .
RUN npm install && npm run build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html

Backend (Node.js)

Dockerfile

FROM node:18-alpine
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 8080
CMD ["node", "server.js"]

🧱 Construir y Subir Imágenes - Desde Cloud Shell

gcloud builds submit --tag us-central1-docker.pkg.dev/queplan/docker-repo/frontend ./frontend

gcloud builds submit --tag us-central1-docker.pkg.dev/queplan/docker-repo/backend ./backend

☁️ Desplegar en Cloud Run
Frontend (público)

gcloud run deploy frontend-service \
  --image us-central1-docker.pkg.dev/NOMBRE_DEL_PROYECTO/docker-repo/frontend \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated

Backend (puede ser privado o público)

gcloud run deploy backend-service \
  --image us-central1-docker.pkg.dev/NOMBRE_DEL_PROYECTO/docker-repo/backend \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated

🔐 Variables de Entorno y Secretos

Para configurar variables en Cloud Run:

gcloud run deploy backend-service \
  --set-env-vars NODE_ENV=production,API_KEY="clave123"

Para secretos, usar Secret Manager y luego referenciarlos.
🌐 Acceso a las Aplicaciones

Después del despliegue, GCP proporcionará URLs públicas para cada servicio.

    Frontend: https://frontend-service-xxxx.a.run.app

    Backend: https://backend-service-xxxx.a.run.app

Puedes integrar el backend desde el frontend usando estas URLs en las variables de entorno o configuración del cliente.


El repositorio se despliega con Cloud Build al hacer un pull request de la branch develop a Main.


