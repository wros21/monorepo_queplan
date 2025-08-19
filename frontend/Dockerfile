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

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
