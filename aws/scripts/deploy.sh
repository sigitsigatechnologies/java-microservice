#!/bin/bash
# ============================================
# Deploy CMS Microservices to AWS
# ============================================
# Usage: ./aws/scripts/deploy.sh [--skip-build]
# ============================================

set -euo pipefail

# Configuration
AWS_REGION="${AWS_REGION:-ap-southeast-1}"
ENVIRONMENT="${ENVIRONMENT:-cms-prod}"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CF_DIR="${PROJECT_DIR}/aws/cloudformation"

# Default credentials - CHANGE THESE!
DB_USERNAME="${DB_USERNAME:-cmsadmin}"
DB_PASSWORD="${DB_PASSWORD:-ChangeMe123!}"
JWT_SECRET="${JWT_SECRET:-MySuperSecretKeyForJwtWhichIsLongEnoughForHmacSHA256SignatureAlgorithm2026!}"

# Parse arguments
SKIP_BUILD=false
for arg in "$@"; do
  case $arg in
    --skip-build) SKIP_BUILD=true ;;
  esac
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}    CMS Microservices - AWS Deployment       ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo -e "AWS Account:  ${YELLOW}${AWS_ACCOUNT_ID}${NC}"
echo -e "AWS Region:   ${YELLOW}${AWS_REGION}${NC}"
echo -e "Environment:  ${YELLOW}${ENVIRONMENT}${NC}"
echo ""

# Function to deploy a CloudFormation stack
deploy_stack() {
  local STACK_NAME=$1
  local TEMPLATE_FILE=$2
  shift 2
  local PARAMS=("$@")

  echo -e "${YELLOW}  Deploying stack: ${STACK_NAME}...${NC}"

  local CMD="aws cloudformation deploy \
    --region ${AWS_REGION} \
    --stack-name ${STACK_NAME} \
    --template-file ${TEMPLATE_FILE} \
    --capabilities CAPABILITY_NAMED_IAM \
    --no-fail-on-empty-changeset"

  if [ ${#PARAMS[@]} -gt 0 ]; then
    CMD="${CMD} --parameter-overrides ${PARAMS[*]}"
  fi

  if eval "${CMD}"; then
    echo -e "${GREEN}  ✓ Stack ${STACK_NAME} deployed successfully${NC}"
  else
    echo -e "${RED}  ✗ Stack ${STACK_NAME} deployment FAILED${NC}"
    echo -e "${RED}    Check CloudFormation console for details${NC}"
    exit 1
  fi
}

# Function to wait for stack
wait_for_stack() {
  local STACK_NAME=$1
  echo -e "${YELLOW}  Waiting for stack ${STACK_NAME} to complete...${NC}"
  aws cloudformation wait stack-create-complete --stack-name "${STACK_NAME}" --region "${AWS_REGION}" 2>/dev/null || \
  aws cloudformation wait stack-update-complete --stack-name "${STACK_NAME}" --region "${AWS_REGION}" 2>/dev/null || true
}

# ============================================
# Step 1: Deploy VPC
# ============================================
echo -e "${BLUE}[1/5] Deploying VPC infrastructure...${NC}"
deploy_stack "${ENVIRONMENT}-vpc" "${CF_DIR}/vpc-stack.yml" \
  "EnvironmentName=${ENVIRONMENT}"
echo ""

# ============================================
# Step 2: Deploy Secrets
# ============================================
echo -e "${BLUE}[2/5] Deploying Secrets Manager...${NC}"
deploy_stack "${ENVIRONMENT}-secrets" "${CF_DIR}/secrets-stack.yml" \
  "EnvironmentName=${ENVIRONMENT}" \
  "DBUsername=${DB_USERNAME}" \
  "DBPassword=${DB_PASSWORD}" \
  "JwtSecret=${JWT_SECRET}"
echo ""

# ============================================
# Step 3: Deploy RDS
# ============================================
echo -e "${BLUE}[3/5] Deploying RDS MySQL...${NC}"
echo -e "${YELLOW}  ⏳ This may take 10-15 minutes...${NC}"
deploy_stack "${ENVIRONMENT}-rds" "${CF_DIR}/rds-stack.yml" \
  "EnvironmentName=${ENVIRONMENT}" \
  "DBUsername=${DB_USERNAME}" \
  "DBPassword=${DB_PASSWORD}"
echo ""

# Get RDS endpoint
RDS_ENDPOINT=$(aws cloudformation describe-stacks \
  --stack-name "${ENVIRONMENT}-rds" \
  --region "${AWS_REGION}" \
  --query "Stacks[0].Outputs[?OutputKey=='RDSEndpoint'].OutputValue" \
  --output text)
echo -e "RDS Endpoint: ${YELLOW}${RDS_ENDPOINT}${NC}"
echo ""

# ============================================
# Step 4: Deploy ECS Cluster + ALB
# ============================================
echo -e "${BLUE}[4/5] Deploying ECS Cluster & ALB...${NC}"
deploy_stack "${ENVIRONMENT}-ecs-cluster" "${CF_DIR}/ecs-cluster-stack.yml" \
  "EnvironmentName=${ENVIRONMENT}"
echo ""

# ============================================
# Step 4.5: Build & Push Docker images
# ============================================
if [ "$SKIP_BUILD" = false ]; then
  echo -e "${BLUE}[4.5] Building & pushing Docker images...${NC}"
  bash "${SCRIPT_DIR}/build-and-push.sh"
  echo ""
fi

# ============================================
# Step 5: Deploy ECS Services
# ============================================
echo -e "${BLUE}[5/5] Deploying ECS Services...${NC}"
deploy_stack "${ENVIRONMENT}-services" "${CF_DIR}/services-stack.yml" \
  "EnvironmentName=${ENVIRONMENT}" \
  "AWSAccountId=${AWS_ACCOUNT_ID}" \
  "AWSRegion=${AWS_REGION}" \
  "RDSEndpoint=${RDS_ENDPOINT}" \
  "RDSUsername=${DB_USERNAME}" \
  "RDSPassword=${DB_PASSWORD}" \
  "JwtSecret=${JWT_SECRET}"
echo ""

# ============================================
# Get ALB URL
# ============================================
ALB_DNS=$(aws cloudformation describe-stacks \
  --stack-name "${ENVIRONMENT}-ecs-cluster" \
  --region "${AWS_REGION}" \
  --query "Stacks[0].Outputs[?OutputKey=='ALBDnsName'].OutputValue" \
  --output text)

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}    Deployment Complete! 🚀                  ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "Application URL: ${YELLOW}http://${ALB_DNS}${NC}"
echo -e "RDS Endpoint:    ${YELLOW}${RDS_ENDPOINT}${NC}"
echo ""
echo -e "API Endpoints:"
echo -e "  Auth:     ${YELLOW}http://${ALB_DNS}/api/auth/**${NC}"
echo -e "  Users:    ${YELLOW}http://${ALB_DNS}/api/users/**${NC}"
echo -e "  Accounts: ${YELLOW}http://${ALB_DNS}/api/accounts/**${NC}"
echo -e "  Transfer: ${YELLOW}http://${ALB_DNS}/api/transfers/**${NC}"
echo -e "  Payroll:  ${YELLOW}http://${ALB_DNS}/api/payroll/**${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Run: ${YELLOW}./aws/scripts/init-rds.sh${NC} to create databases"
echo -e "  2. Wait 2-3 minutes for services to become healthy"
echo -e "  3. Test: ${YELLOW}curl http://${ALB_DNS}/actuator/health${NC}"
echo ""
echo -e "${BLUE}To check service status:${NC}"
echo -e "  ${YELLOW}aws ecs list-services --cluster ${ENVIRONMENT}-cluster --region ${AWS_REGION}${NC}"
echo -e "  ${YELLOW}aws ecs describe-services --cluster ${ENVIRONMENT}-cluster --services api-gateway auth-service --region ${AWS_REGION}${NC}"
