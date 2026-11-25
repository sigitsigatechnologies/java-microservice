#!/bin/bash
# ============================================
# Initialize RDS MySQL Databases
# ============================================
# Creates all 7 databases required by the microservices
# Usage: ./aws/scripts/init-rds.sh
# ============================================

set -euo pipefail

# Configuration
AWS_REGION="${AWS_REGION:-ap-southeast-1}"
ENVIRONMENT="${ENVIRONMENT:-cms-prod}"
DB_USERNAME="${DB_USERNAME:-cmsadmin}"
DB_PASSWORD="${DB_PASSWORD:-ChangeMe123!}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  CMS - Initialize RDS Databases             ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Get RDS endpoint from CloudFormation
RDS_ENDPOINT=$(aws cloudformation describe-stacks \
  --stack-name "${ENVIRONMENT}-rds" \
  --region "${AWS_REGION}" \
  --query "Stacks[0].Outputs[?OutputKey=='RDSEndpoint'].OutputValue" \
  --output text)

echo -e "RDS Endpoint: ${YELLOW}${RDS_ENDPOINT}${NC}"
echo ""

# Check if mysql client is available
if ! command -v mysql &> /dev/null; then
  echo -e "${YELLOW}mysql client not found. Installing options:${NC}"
  echo -e "  macOS:  ${YELLOW}brew install mysql-client${NC}"
  echo -e "  Ubuntu: ${YELLOW}sudo apt-get install mysql-client${NC}"
  echo ""
  echo -e "${BLUE}Alternative: Use AWS CloudShell or connect via a bastion host.${NC}"
  echo ""
  echo -e "SQL to execute manually:"
  echo "  CREATE DATABASE IF NOT EXISTS auth_db;"
  echo "  CREATE DATABASE IF NOT EXISTS user_db;"
  echo "  CREATE DATABASE IF NOT EXISTS account_db;"
  echo "  CREATE DATABASE IF NOT EXISTS transfer_db;"
  echo "  CREATE DATABASE IF NOT EXISTS payroll_db;"
  echo "  CREATE DATABASE IF NOT EXISTS transaction_db;"
  echo "  CREATE DATABASE IF NOT EXISTS notification_db;"
  exit 0
fi

# Note: RDS is in a private subnet, so you need to connect via:
# 1. A bastion host in the public subnet, OR
# 2. AWS Systems Manager Session Manager, OR
# 3. Temporarily allow your IP in the security group

echo -e "${YELLOW}⚠️  Note: RDS is in a private subnet.${NC}"
echo -e "${YELLOW}   You may need to use a bastion host or VPN to connect.${NC}"
echo ""
echo -e "${BLUE}Option 1: Use AWS CloudShell (easiest)${NC}"
echo -e "  1. Open AWS CloudShell in the console"
echo -e "  2. Run the SQL commands below"
echo ""
echo -e "${BLUE}Option 2: Use the ECS Exec feature${NC}"
echo -e "  Run this from any running ECS task:"
echo ""

# Create SQL file
SQL_COMMANDS="
CREATE DATABASE IF NOT EXISTS auth_db;
CREATE DATABASE IF NOT EXISTS user_db;
CREATE DATABASE IF NOT EXISTS account_db;
CREATE DATABASE IF NOT EXISTS transfer_db;
CREATE DATABASE IF NOT EXISTS payroll_db;
CREATE DATABASE IF NOT EXISTS transaction_db;
CREATE DATABASE IF NOT EXISTS notification_db;

-- Verify
SHOW DATABASES;
"

echo -e "${BLUE}SQL Commands to execute:${NC}"
echo -e "${YELLOW}${SQL_COMMANDS}${NC}"
echo ""

# Try to connect directly (will work if you have network access to the RDS)
echo -e "${BLUE}Attempting direct connection...${NC}"
if mysql -h "${RDS_ENDPOINT}" -u "${DB_USERNAME}" -p"${DB_PASSWORD}" -e "${SQL_COMMANDS}" 2>/dev/null; then
  echo -e "${GREEN}✓ All databases created successfully!${NC}"
else
  echo -e "${YELLOW}⚠️  Could not connect directly (expected if RDS is in private subnet)${NC}"
  echo -e "${YELLOW}   Use one of the alternative methods above.${NC}"
fi

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Database initialization guide complete     ${NC}"
echo -e "${GREEN}============================================${NC}"
