#!/bin/bash

# Configurar variáveis de ambiente no Beanstalk para RDS
# Usage: ./configure-rds.sh

source .env

echo "🔧 Configurando variáveis RDS no Beanstalk..."

aws elasticbeanstalk update-environment \
  --environment-name "$ENVIRONMENT_NAME" \
  --option-settings \
    "Namespace=aws:elasticbeanstalk:application:environment,OptionName=DB_HOST,Value=$DB_HOST" \
    "Namespace=aws:elasticbeanstalk:application:environment,OptionName=DB_USER,Value=$DB_USER" \
    "Namespace=aws:elasticbeanstalk:application:environment,OptionName=DB_PWD,Value=$DB_PWD" \
    "Namespace=aws:elasticbeanstalk:application:environment,OptionName=DB_PORT,Value=$DB_PORT" \
    "Namespace=aws:elasticbeanstalk:application:environment,OptionName=NODE_ENV,Value=production" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE"

echo "✅ Variáveis configuradas!"
