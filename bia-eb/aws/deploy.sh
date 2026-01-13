#!/bin/bash

# Configurações
APP_NAME="tasks-app"
ENVIRONMENT_NAME="tasks-dev"
AWS_REGION="us-east-1"
AWS_PROFILE="${AWS_PROFILE:-default}"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verificar se foi passado o version label
if [ -z "$1" ]; then
    echo -e "${RED}❌ Usage: ./deploy.sh <version-label>${NC}"
    echo -e "${YELLOW}💡 Example: ./deploy.sh v-20241210-142530${NC}"
    exit 1
fi

VERSION_LABEL=$1

echo -e "${BLUE}🚀 Starting deployment...${NC}"
echo -e "${YELLOW}📋 Version: $VERSION_LABEL${NC}"
echo -e "${YELLOW}📋 Environment: $ENVIRONMENT_NAME${NC}"

# Deploy para o ambiente
echo -e "${YELLOW}☁️ Deploying to Beanstalk environment...${NC}"
aws elasticbeanstalk update-environment \
  --environment-name $ENVIRONMENT_NAME \
  --version-label $VERSION_LABEL \
  --description "Deploy container version $VERSION_LABEL" \
  --region $AWS_REGION \
  --profile $AWS_PROFILE

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Deployment initiated successfully!${NC}"
    echo -e "${BLUE}📋 Monitor deployment at:${NC}"
    echo -e "   https://console.aws.amazon.com/elasticbeanstalk/home?region=$AWS_REGION#/environment/dashboard?applicationName=$APP_NAME&environmentId=$ENVIRONMENT_NAME"
    echo ""
    echo -e "${YELLOW}⏳ Deployment usually takes 2-5 minutes...${NC}"
    echo -e "${BLUE}🌐 URL: your-app.region.elasticbeanstalk.com${NC}"
else
    echo -e "${RED}❌ Deployment failed!${NC}"
    exit 1
fi
