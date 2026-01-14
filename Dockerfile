# Stage 1: Build do Frontend
FROM node:18-alpine AS frontend-build

WORKDIR /app/frontend

# Copiar package.json do frontend
COPY frontend/package*.json ./

# Instalar dependências com timeout e sem optional
RUN npm ci --legacy-peer-deps --no-optional --prefer-offline --no-audit 2>&1 || \
    npm install --legacy-peer-deps --no-optional --prefer-offline --no-audit

# Copiar código do frontend e fazer build
COPY frontend/ ./
RUN npm run build

# Stage 2: Backend + Frontend buildado
FROM node:18-alpine

WORKDIR /usr/src/app

# Copiar package.json do backend
COPY backend/package*.json ./
RUN npm ci --only=production --no-audit --no-optional

# Copiar código do backend
COPY backend/ ./

# Copiar frontend buildado do stage anterior
COPY --from=frontend-build /app/frontend/build ./client/build/

EXPOSE 80
CMD ["node", "index.js"]
