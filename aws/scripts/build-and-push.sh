#!/bin/bash
# ============================================
# Build and Push Docker Images to AWS ECR
# ============================================
# Usage: ./aws/scripts/build-and-push.sh
# ============================================

set -euo pipefail

# Configuration
AWS_REGION="${AWS_REGION:-ap-southeast-1}"
ENVIRONMENT="${ENVIRONMENT:-cms-prod}"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Service list
SERVICES=(
  "api-gateway"
  "auth-service"
  "user-service"
  "account-service"
  "transfer-service"
  "payroll-service"
  "transaction-service"
  "notification-service"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  CMS Microservices - Build & Push to ECR   ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo -e "AWS Account:  ${YELLOW}${AWS_ACCOUNT_ID}${NC}"
echo -e "AWS Region:   ${YELLOW}${AWS_REGION}${NC}"
echo -e "ECR Registry: ${YELLOW}${ECR_REGISTRY}${NC}"
echo -e "Environment:  ${YELLOW}${ENVIRONMENT}${NC}"
echo ""

# Step 1: Login to ECR
echo -e "${BLUE}[1/3] Logging in to ECR...${NC}"
aws ecr get-login-password --region "${AWS_REGION}" | \
  docker login --username AWS --password-stdin "${ECR_REGISTRY}"
echo -e "${GREEN}✓ ECR login successful${NC}"
echo ""

# Step 2: Build Docker images
echo -e "${BLUE}[2/3] Building Docker images...${NC}"
FAILED_BUILDS=()
for SERVICE in "${SERVICES[@]}"; do
  IMAGE_NAME="${ECR_REGISTRY}/${ENVIRONMENT}/${SERVICE}"
  echo -e "${YELLOW}  Building ${SERVICE}...${NC}"
  
  if docker build -t "${IMAGE_NAME}:latest" \
    -t "${IMAGE_NAME}:$(date +%Y%m%d-%H%M%S)" \
    "./${SERVICE}" 2>&1; then
    echo -e "${GREEN}  ✓ ${SERVICE} built successfully${NC}"
  else
    echo -e "${RED}  ✗ ${SERVICE} build FAILED${NC}"
    FAILED_BUILDS+=("${SERVICE}")
  fi
done
echo ""

if [ ${#FAILED_BUILDS[@]} -gt 0 ]; then
  echo -e "${RED}The following services failed to build:${NC}"
  for FAILED in "${FAILED_BUILDS[@]}"; do
    echo -e "${RED}  - ${FAILED}${NC}"
  done
  echo -e "${RED}Fix the errors above and re-run this script.${NC}"
  exit 1
fi

# Step 3: Push images to ECR
echo -e "${BLUE}[3/3] Pushing images to ECR...${NC}"
for SERVICE in "${SERVICES[@]}"; do
  IMAGE_NAME="${ECR_REGISTRY}/${ENVIRONMENT}/${SERVICE}"
  echo -e "${YELLOW}  Pushing ${SERVICE}...${NC}"
  docker push "${IMAGE_NAME}" --all-tags
  echo -e "${GREEN}  ✓ ${SERVICE} pushed successfully${NC}"
done
echo ""

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  All images built and pushed successfully!  ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "Images pushed to: ${YELLOW}${ECR_REGISTRY}/${ENVIRONMENT}/*${NC}"
