# Stage 1: Build the Angular app
FROM node:lts-alpine as build

ARG API_URL
ENV API_URL=${API_URL}
WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .

RUN if [ -n "$API_URL" ]; then \
      sed -i "s|__BACKEND_API_URL__|${API_URL}|g" src/environments/environment.prod.ts; \
    fi

# Build the Angular app
RUN npm run build

# Stage 2: Serve using Nginx
FROM nginx:latest

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy built Angular app from Stage 1
COPY --from=build /app/dist/notes-app /usr/share/nginx/html

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

