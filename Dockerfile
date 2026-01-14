# Stage 1: Build Frontend
FROM node:18-alpine AS frontend-builder

WORKDIR /frontend

# Copiar package.json e instalar dependências
COPY frontend/package*.json ./
RUN NODE_OPTIONS="--max-old-space-size=1536" npm ci --legacy-peer-deps --no-optional --no-audit

# Copiar código e fazer build
COPY frontend/ ./
RUN NODE_OPTIONS="--max-old-space-size=1536" npm run build

# Stage 2: Backend + Frontend
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
COPY --from=frontend-builder /frontend/build ./client/build

EXPOSE 80
CMD ["node", "index.js"]
