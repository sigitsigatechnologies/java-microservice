#!/bin/bash

# Create logs directory
mkdir -p logs

echo "Starting API Gateway..."
nohup ./api-gateway/mvnw spring-boot:run -f api-gateway/pom.xml > logs/api-gateway.log 2>&1 &
echo $! > logs/api-gateway.pid

echo "Starting Auth Service..."
nohup ./auth-service/mvnw spring-boot:run -f auth-service/pom.xml > logs/auth-service.log 2>&1 &
echo $! > logs/auth-service.pid

echo "Starting User Service..."
nohup ./user-service/mvnw spring-boot:run -f user-service/pom.xml > logs/user-service.log 2>&1 &
echo $! > logs/user-service.pid

echo "Starting Account Service..."
nohup ./account-service/mvnw spring-boot:run -f account-service/pom.xml > logs/account-service.log 2>&1 &
echo $! > logs/account-service.pid

echo "Starting Transfer Service..."
nohup ./transfer-service/mvnw spring-boot:run -f transfer-service/pom.xml > logs/transfer-service.log 2>&1 &
echo $! > logs/transfer-service.pid

echo "Starting Payroll Service..."
nohup ./payroll-service/mvnw spring-boot:run -f payroll-service/pom.xml > logs/payroll-service.log 2>&1 &
echo $! > logs/payroll-service.pid

echo "Starting Transaction Service..."
nohup ./transaction-service/mvnw spring-boot:run -f transaction-service/pom.xml > logs/transaction-service.log 2>&1 &
echo $! > logs/transaction-service.pid

echo "Starting Notification Service..."
nohup ./notification-service/mvnw spring-boot:run -f notification-service/pom.xml > logs/notification-service.log 2>&1 &
echo $! > logs/notification-service.pid

echo "All services started in background. Logs are in the logs/ directory."
