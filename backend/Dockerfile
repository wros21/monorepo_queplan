# Use an official Node.js LTS version as base
FROM node:lts-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install --only=production

COPY . .

# No es necesario cambiar EXPOSE, Cloud Run ignora este puerto, pero lo dejamos para documentación
EXPOSE 3000

# Usar la variable PORT que Cloud Run define
ENV PORT 3000

CMD ["node", "server.js"]
