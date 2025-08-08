# Stage 1: Build the Angular app
FROM node:lts-alpine as build

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Build the Angular app (use default outputPath from angular.json)
RUN npm run build

# Stage 2: Serve using Nginx
FROM nginx:latest

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy built Angular app from Stage 1
COPY --from=build /app/dist/notes-app /usr/share/nginx/html

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]