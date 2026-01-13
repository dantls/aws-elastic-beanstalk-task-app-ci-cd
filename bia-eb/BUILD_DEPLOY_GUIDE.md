# 🚀 Build & Deploy Guide - Tasks Application

## 📋 Estrutura do Projeto

```
tasks-application/
├── app/
│   ├── backend/           # API Node.js + Sequelize
│   ├── frontend/          # React App
│   └── Dockerfile         # Container da aplicação
├── aws/
│   ├── .env              # Configurações AWS
│   ├── build-and-push-public.sh  # Script de build e push ECR
│   ├── deploy.sh         # Script de deploy Beanstalk
│   └── .ebextensions/    # Configurações Beanstalk
└── BUILD_DEPLOY_GUIDE.md # Este arquivo
```

## ⚠️ Correções Necessárias

### 🔧 Problemas Encontrados e Soluções

**1. Script build-and-push-public.sh - Paths incorretos**
```bash
# PROBLEMA: Script mudava para diretório errado
cd "$(dirname "$0")/.."  # ❌ Causava erro "path not found"

# SOLUÇÃO: Comentar linha e executar da pasta aws/
# cd "$(dirname "$0")/.."  # ✅ Comentado
```

**2. Caminhos relativos no script**
```bash
# PROBLEMA: Referências antigas para aws-infrastructure/
cat > aws-infrastructure/Dockerrun.aws.json  # ❌

# SOLUÇÃO: Usar paths relativos corretos
cat > Dockerrun.aws.json  # ✅
zip -r ${APP_NAME}-${TAG}.zip Dockerrun.aws.json .ebextensions/  # ✅
```

**3. Deploy script - Credenciais AWS**
```bash
# PROBLEMA: Token inválido sem carregar .env
./deploy.sh v-20251212-112632  # ❌

# SOLUÇÃO: Sempre carregar environment primeiro
source .env && ./deploy.sh v-20251212-112632  # ✅
```

### 📋 Processo Correto Após Reorganização

**1. Build e Push:**
```bash
cd aws
source .env
./build-and-push-public.sh
```

**2. Deploy:**
```bash
# Já na pasta aws/
source .env && ./deploy.sh v-YYYYMMDD-HHMMSS
```

### ✅ Validações Importantes

- ✅ Executar sempre da pasta `aws/`
- ✅ Sempre fazer `source .env` antes dos comandos
- ✅ Verificar se `../app/` existe antes do build
- ✅ Confirmar que frontend tem build/ atualizado

## ⚙️ Configurações Atuais

### AWS Profile: `<your-profile>`
### Aplicação: `tasks-app`
### Ambiente: `tasks-dev`
### Região: `us-east-1`
### URL: `<your-app-url>.elasticbeanstalk.com`

## 🔄 Processo de Build & Deploy

### 1. Build e Push para ECR
```bash
cd aws
source .env
./build-and-push-public.sh
```

**O que faz:**
- Faz build da imagem Docker da aplicação
- Faz push para ECR com tag timestamp
- Cria Dockerrun.aws.json
- Cria versão no Beanstalk
- Limpa arquivos temporários (node_modules, build)

### 2. Deploy no Beanstalk
```bash
cd aws
./deploy.sh v-YYYYMMDD-HHMMSS
```

**Exemplo:**
```bash
./deploy.sh v-20251212-071205
```

## 📝 Arquivos Importantes

### .env (aws-infrastructure/.env)
```bash
export APP_NAME="tasks-app"
export AWS_REGION="us-east-1"
export AWS_PROFILE="<your-aws-profile>"
export ENVIRONMENT_NAME="tasks-dev"
export DB_HOST="<your-rds-endpoint>"
export DB_USER="postgres"
export DB_PWD='<your-db-password>'
export DB_PORT="5432"
```

### Dockerfile (app/Dockerfile)
```dockerfile
FROM node:18-alpine
WORKDIR /usr/src/app
COPY backend/package*.json ./
RUN npm ci --only=production --no-audit
COPY backend/ ./
EXPOSE 80
CMD ["node", "index.js"]
```

## 🎯 API Endpoints

- **Base URL:** `http://<your-app-url>.elasticbeanstalk.com`
- **API:** `/api/tarefas`

### Rotas:
- `GET /api/tarefas` - Listar todas
- `POST /api/tarefas` - Criar nova
- `GET /api/tarefas/:uuid` - Buscar por ID
- `PUT /api/tarefas/:uuid` - Atualizar
- `DELETE /api/tarefas/:uuid` - Deletar

## 🗄️ Banco de Dados

- **RDS PostgreSQL**
- **Host:** `<your-rds-endpoint>`
- **Porta:** `5432`
- **Database:** `tasks_app`
- **SSL:** Habilitado

## 🔧 Troubleshooting

### Erro de Profile AWS
Se aparecer "profile not found":
1. Verificar se profile `formacaoaws` existe: `aws configure list-profiles`
2. Corrigir no script se necessário

### Erro de Build
1. Verificar se Docker está rodando: `docker --version`
2. Verificar se está no diretório correto
3. Verificar se .env está carregado: `source .env`

### Erro de Deploy
1. Verificar se versão existe no Beanstalk
2. Verificar logs no console AWS
3. Aguardar deploy anterior terminar

## 📊 Monitoramento

- **Console AWS:** https://console.aws.amazon.com/elasticbeanstalk/
- **Logs:** CloudWatch Logs
- **Health:** Beanstalk Dashboard

## 🚨 Importante

1. **Sempre usar .env do projeto** (não criar externos)
2. **Aguardar build terminar** antes de fazer deploy
3. **Verificar se aplicação anterior está funcionando** antes de nova versão
4. **Deploy demora 2-5 minutos** - aguardar conclusão

## 📋 Checklist Rápido

- [ ] `cd aws`
- [ ] `source .env`
- [ ] `./build-and-push-public.sh`
- [ ] Aguardar conclusão (ver tag gerada)
- [ ] `./deploy.sh v-TAG`
- [ ] Monitorar no console AWS
- [ ] Testar API após deploy

---
**Última atualização:** 2025-12-12
**Versão atual:** v-20251212-071205
