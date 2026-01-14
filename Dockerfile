# Stage 1: Build do Frontend
FROM node:18-alpine AS frontend-build

WORKDIR /app/frontend

# Copiar package.json do frontend
COPY frontend/package*.json ./
RUN npm ci --legacy-peer-deps

# Copiar código do frontend e fazer build
COPY frontend/ ./
RUN npm run build

# Stage 2: Backend + Frontend buildado
FROM node:18-alpine

WORKDIR /usr/src/app

# Copiar package.json do backend
COPY backend/package*.json ./
RUN npm ci --only=production --no-audit

# Copiar código do backend
COPY backend/api ./api
COPY backend/lib ./lib
COPY backend/config ./config
COPY backend/database ./database
COPY backend/index.js ./
COPY backend/tustas.js ./
COPY backend/db.js ./

# Copiar frontend buildado do stage anterior
COPY --from=frontend-build /app/frontend/build ./client/build/

EXPOSE 80
CMD ["node", "index.js"]
