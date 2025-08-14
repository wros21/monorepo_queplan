# Stage 1: Build the Angular app
FROM node:lts-alpine as build

# Argumento para la URL de la API
ARG API_URL
ENV API_URL=${API_URL}
WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .

# Reemplazar la URL del placeholder en environment.prod.ts
RUN sed -i "s|API_URL_PLACEHOLDER|${API_URL}|g" src/environments/environment.prod.ts

# Build the Angular app (use default outputPath from angular.json)
RUN npm run build

# Stage 2: Serve using Nginx
FROM nginx:latest

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy built Angular app from Stage 1
COPY --from=build /app/dist/notes-app /usr/share/nginx/html

# Create custom nginx configuration for port 8080
RUN echo 'server {' > /etc/nginx/conf.d/default.conf && \
    echo '    listen 8080;' >> /etc/nginx/conf.d/default.conf && \
    echo '    server_name localhost;' >> /etc/nginx/conf.d/default.conf && \
    echo '    root /usr/share/nginx/html;' >> /etc/nginx/conf.d/default.conf && \
    echo '    index index.html;' >> /etc/nginx/conf.d/default.conf && \
    echo '    location / {' >> /etc/nginx/conf.d/default.conf && \
    echo '        try_files $uri $uri/ /index.html;' >> /etc/nginx/conf.d/default.conf && \
    echo '    }' >> /etc/nginx/conf.d/default.conf && \
    echo '}' >> /etc/nginx/conf.d/default.conf

# Expose port 8080
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]