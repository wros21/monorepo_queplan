# Stage 1: Build the Angular app
FROM node:lts-alpine as build

ARG API_URL
ENV API_URL=${API_URL}
WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .

# Reemplaza la URL del backend si se pasa API_URL
RUN if [ -n "$API_URL" ]; then \
      sed -i "s|__BACKEND_API_URL__|${API_URL}|g" src/environments/environment.prod.ts; \
    fi

# Build la app Angular
RUN npm run build

# Stage 2: Serve using Nginx
FROM nginx:stable-alpine

# Limpiar default html
RUN rm -rf /usr/share/nginx/html/*

# Copiar la app construida
COPY --from=build /app/dist/notes-app /usr/share/nginx/html

# Crear nginx.conf dinámico usando la variable PORT
ENV PORT 80
RUN echo "events {}\nhttp {\n  server {\n    listen ${PORT};\n    location / {\n      root /usr/share/nginx/html;\n      index index.html index.htm;\n      try_files \$uri /index.html;\n    }\n  }\n}" > /etc/nginx/conf.d/default.conf

EXPOSE 80

# CMD para Cloud Run
CMD ["nginx", "-g", "daemon off;"]
