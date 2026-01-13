#!/bin/bash

# Configurações - CUSTOMIZE THESE VALUES
APP_NAME="${APP_NAME:-tasks-app}"
AWS_REGION="${AWS_REGION:-us-east-1}"
AWS_PROFILE="${AWS_PROFILE:-default}"
ECR_REPO="${APP_NAME}-repo"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Starting build and push process...${NC}"

# Ir para o diretório raiz do projeto (comentado - agora executamos da pasta aws)
# cd "$(dirname "$0")/.."

# 1. Verificar se Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# 2. Obter Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --profile $AWS_PROFILE --query Account --output text)
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to get AWS Account ID${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Account ID: $ACCOUNT_ID${NC}"

# 3. Obter bucket do Beanstalk automaticamente
BUCKET_NAME=$(aws s3api list-buckets --profile $AWS_PROFILE --query "Buckets[?contains(Name, 'elasticbeanstalk-${AWS_REGION}')].Name" --output text | head -1)
if [ -z "$BUCKET_NAME" ]; then
    echo -e "${RED}❌ No Beanstalk S3 bucket found. Create a Beanstalk application first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Using S3 bucket: $BUCKET_NAME${NC}"

# 4. Criar ECR repository se não existir
echo -e "${YELLOW}📦 Checking ECR repository...${NC}"
aws ecr describe-repositories --repository-names $ECR_REPO --region $AWS_REGION --profile $AWS_PROFILE > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}📦 Creating ECR repository: $ECR_REPO${NC}"
    aws ecr create-repository --repository-name $ECR_REPO --region $AWS_REGION --profile $AWS_PROFILE
fi

# 5. Login no ECR
echo -e "${YELLOW}🔐 Logging into ECR...${NC}"
aws ecr get-login-password --region $AWS_REGION --profile $AWS_PROFILE | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# 6. Build da imagem React (se necessário)
if [ -d "../app/frontend/src" ]; then
    echo -e "${YELLOW}⚛️ Building React app...${NC}"
    cd ../app/frontend
    npm install
    NODE_OPTIONS="--openssl-legacy-provider" GENERATE_SOURCEMAP=false npm run build
    cd ../../aws
    
    # Limpar arquivos de desenvolvimento do frontend
    echo -e "${YELLOW}🧹 Cleaning frontend dev files...${NC}"
    rm -rf app/frontend/src app/frontend/public app/frontend/package*.json app/frontend/node_modules app/frontend/yarn.lock
fi

# 7. Gerar tag baseada no timestamp
TAG=$(date +%Y%m%d-%H%M%S)
IMAGE_URI="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$TAG"
LATEST_URI="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest"

echo -e "${YELLOW}🏗️ Building Docker image with tag: $TAG${NC}"

# 8. Build da imagem Docker
docker build -t $ECR_REPO:$TAG ../app/
docker tag $ECR_REPO:$TAG $IMAGE_URI
docker tag $ECR_REPO:$TAG $LATEST_URI

# 9. Push para ECR
echo -e "${YELLOW}📤 Pushing to ECR...${NC}"
docker push $IMAGE_URI
docker push $LATEST_URI

# 10. Limpeza pós-push
echo -e "${YELLOW}🧹 Cleaning up after ECR push...${NC}"
rm -rf ../app/backend/node_modules
rm -rf ../app/frontend/build
echo -e "${GREEN}✅ Build artifacts cleaned!${NC}"

# 11. Criar Dockerrun.aws.json para Beanstalk
echo -e "${YELLOW}📝 Creating Dockerrun.aws.json...${NC}"
cat > Dockerrun.aws.json << EOF
{
  "AWSEBDockerrunVersion": "1",
  "Image": {
    "Name": "$IMAGE_URI",
    "Update": "true"
  },
  "Ports": [
    {
      "ContainerPort": "80"
    }
  ]
}
EOF

# 12. Criar ZIP para deploy
echo -e "${YELLOW}📦 Creating deployment package...${NC}"
zip -r ${APP_NAME}-${TAG}.zip Dockerrun.aws.json .ebextensions/

# 13. Upload para S3 e criar versão no Beanstalk
echo -e "${YELLOW}☁️ Uploading to S3 and creating Beanstalk version...${NC}"
aws s3 cp ${APP_NAME}-${TAG}.zip s3://${BUCKET_NAME}/${APP_NAME}-${TAG}.zip --profile $AWS_PROFILE

aws elasticbeanstalk create-application-version \
  --application-name $APP_NAME \
  --version-label "v-$TAG" \
  --description "Container build $TAG from ECR" \
  --source-bundle S3Bucket="$BUCKET_NAME",S3Key="${APP_NAME}-${TAG}.zip" \
  --region $AWS_REGION \
  --profile $AWS_PROFILE

echo -e "${GREEN}✅ Build and push completed!${NC}"
echo -e "${BLUE}📋 Summary:${NC}"
echo -e "   Image URI: $IMAGE_URI"
echo -e "   Tag: $TAG"
echo -e "   Deployment package: ${APP_NAME}-${TAG}.zip"
echo -e "   Beanstalk version: v-$TAG"
echo ""
echo -e "${YELLOW}🚀 To deploy, run:${NC}"
echo -e "   cd aws && ./deploy.sh v-$TAG"
