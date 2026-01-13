#!/bin/bash

# 🚀 Script de Migração para Nova Arquitetura
# Separa frontend/backend e prepara para pipeline AWS

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Iniciando migração para arquitetura separada...${NC}"

# Diretório base
BASE_DIR="/home/danilo/projectchallenge/modjan2026/challenge1"
OLD_DIR="$BASE_DIR/bia-eb"

# 1. Criar nova estrutura
echo -e "${YELLOW}📁 Criando nova estrutura de diretórios...${NC}"
mkdir -p "$BASE_DIR/frontend"
mkdir -p "$BASE_DIR/backend" 
mkdir -p "$BASE_DIR/infrastructure/cloudformation"
mkdir -p "$BASE_DIR/infrastructure/pipeline"
mkdir -p "$BASE_DIR/docs"

# 2. Mover frontend
echo -e "${YELLOW}⚛️ Movendo frontend React...${NC}"
if [ -d "$OLD_DIR/app/frontend" ]; then
    cp -r "$OLD_DIR/app/frontend/"* "$BASE_DIR/frontend/"
    echo -e "${GREEN}✅ Frontend movido com sucesso${NC}"
else
    echo -e "${RED}❌ Diretório frontend não encontrado${NC}"
fi

# 3. Mover backend
echo -e "${YELLOW}🔧 Movendo backend Node.js...${NC}"
if [ -d "$OLD_DIR/app/backend" ]; then
    cp -r "$OLD_DIR/app/backend/"* "$BASE_DIR/backend/"
    echo -e "${GREEN}✅ Backend movido com sucesso${NC}"
else
    echo -e "${RED}❌ Diretório backend não encontrado${NC}"
fi

# 4. Mover documentação existente
echo -e "${YELLOW}📚 Movendo documentação...${NC}"
if [ -f "$OLD_DIR/README.md" ]; then
    cp "$OLD_DIR/README.md" "$BASE_DIR/docs/OLD_README.md"
fi
if [ -f "$OLD_DIR/BUILD_DEPLOY_GUIDE.md" ]; then
    cp "$OLD_DIR/BUILD_DEPLOY_GUIDE.md" "$BASE_DIR/docs/OLD_BUILD_GUIDE.md"
fi
if [ -f "$OLD_DIR/AWS_INFRASTRUCTURE_REPORT.md" ]; then
    cp "$OLD_DIR/AWS_INFRASTRUCTURE_REPORT.md" "$BASE_DIR/docs/OLD_INFRASTRUCTURE.md"
fi

# 5. Preservar configurações AWS
echo -e "${YELLOW}☁️ Preservando configurações AWS...${NC}"
if [ -d "$OLD_DIR/aws" ]; then
    mkdir -p "$BASE_DIR/infrastructure/legacy"
    cp -r "$OLD_DIR/aws/"* "$BASE_DIR/infrastructure/legacy/"
fi

echo -e "${GREEN}✅ Migração concluída!${NC}"
echo -e "${BLUE}📋 Nova estrutura criada em: $BASE_DIR${NC}"
echo -e "${YELLOW}📖 Próximos passos:${NC}"
echo -e "   1. Revisar código frontend/backend"
echo -e "   2. Criar buildspec.yml para cada componente"
echo -e "   3. Configurar pipeline CodePipeline"
echo -e "   4. Configurar S3 + CloudFront"
echo -e "   5. Testar deploy separado"
