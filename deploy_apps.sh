#!/bin/bash

# ==============================================================================
# LOCAL DEPLOYMENT SCRIPT
# Because GitHub-hosted runners cannot reach private 192.168.56.x IPs,
# this script simulates the deployment portion of the CI/CD pipeline locally.
# ==============================================================================

BACKEND_IP="192.168.56.14"
WEB1_IP="192.168.56.12"
WEB2_IP="192.168.56.13"

echo "Deploying Application Containers to VMs..."

# Deploy Backend
echo "Deploying Backend to App Server (${BACKEND_IP})..."
ssh -i .vagrant/machines/appserver/vmware_desktop/private_key -o StrictHostKeyChecking=no devops@${BACKEND_IP} '
  echo "Building backend image..."
  cd /vagrant/backend
  docker build -t vitals-backend:latest .
  
  echo "Running backend container..."
  docker stop vitals-backend-app || true
  docker rm vitals-backend-app || true
  docker run -d --name vitals-backend-app --restart always -p 8080:8080 vitals-backend:latest
'

# Deploy Frontend to Web1
echo "Deploying Frontend to Web Server 1 (${WEB1_IP})..."
ssh -i .vagrant/machines/webserver1/vmware_desktop/private_key -o StrictHostKeyChecking=no devops@${WEB1_IP} '
  echo "Building frontend image..."
  cd /vagrant/frontend
  docker build -t vitals-frontend:latest .
  
  echo "Running frontend container..."
  docker stop vitals-frontend-app || true
  docker rm vitals-frontend-app || true
  docker run -d --name vitals-frontend-app --restart always -p 3000:3000 -e BACKEND_URL=http://192.168.56.14:8080 vitals-frontend:latest
'

# Deploy Frontend to Web2
echo "Deploying Frontend to Web Server 2 (${WEB2_IP})..."
ssh -i .vagrant/machines/webserver2/vmware_desktop/private_key -o StrictHostKeyChecking=no devops@${WEB2_IP} '
  echo "Building frontend image..."
  cd /vagrant/frontend
  docker build -t vitals-frontend:latest .
  
  echo "Running frontend container..."
  docker stop vitals-frontend-app || true
  docker rm vitals-frontend-app || true
  docker run -d --name vitals-frontend-app --restart always -p 3000:3000 -e BACKEND_URL=http://192.168.56.14:8080 vitals-frontend:latest
'

echo "All applications deployed successfully!"
