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

# Copiar frontend buildado
COPY frontend/build/ ./client/build/

EXPOSE 80
CMD ["node", "index.js"]
