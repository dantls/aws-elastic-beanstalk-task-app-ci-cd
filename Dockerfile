# Stage 1: Build Frontend
FROM node:18-alpine AS frontend-builder

WORKDIR /frontend

COPY frontend/package*.json ./
RUN npm ci --legacy-peer-deps --no-optional --no-audit

COPY frontend/ ./
RUN NODE_OPTIONS="--openssl-legacy-provider" npm run build

# Stage 2: Backend + Frontend
FROM node:18-alpine

WORKDIR /usr/src/app

COPY backend/package*.json ./
RUN npm ci --only=production --no-audit

COPY backend/api ./api
COPY backend/lib ./lib
COPY backend/config ./config
COPY backend/database ./database
COPY backend/index.js ./
COPY backend/tustas.js ./
COPY backend/db.js ./

COPY --from=frontend-builder /frontend/build ./client/build

EXPOSE 80
CMD ["node", "index.js"]
