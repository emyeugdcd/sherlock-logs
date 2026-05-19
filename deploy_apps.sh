#!/bin/bash

# ==============================================================================
# LOCAL DEPLOYMENT SCRIPT
# Because GitHub-hosted runners cannot reach private 192.168.56.x IPs,
# this script simulates the deployment portion of the CI/CD pipeline locally.
# ==============================================================================

BACKEND_IP="192.168.56.14"
WEB1_IP="192.168.56.12"
WEB2_IP="192.168.56.13"

set -e  # Exit immediately on error

# ==============================================================================
# AUTO-DETECT VAGRANT PROVIDER
# Checks which provider directory exists under .vagrant/machines/appserver/
# ==============================================================================
detect_provider() {
  local machine_dir=".vagrant/machines/appserver"

  if [ -f "${machine_dir}/vmware_desktop/private_key" ]; then
    echo "vmware_desktop"
  elif [ -f "${machine_dir}/vmware_fusion/private_key" ]; then
    echo "vmware_fusion"
  elif [ -f "${machine_dir}/virtualbox/private_key" ]; then
    echo "virtualbox"
  else
    echo ""
  fi
}

PROVIDER=$(detect_provider)

if [ -z "$PROVIDER" ]; then
  echo "ERROR: Could not detect Vagrant provider."
  echo "Make sure you have run 'vagrant up' before running this script."
  echo "Expected key in one of:"
  echo "  .vagrant/machines/appserver/vmware_desktop/private_key"
  echo "  .vagrant/machines/appserver/vmware_fusion/private_key"
  echo "  .vagrant/machines/appserver/virtualbox/private_key"
  exit 1
fi

echo "Detected provider: ${PROVIDER}"

# ==============================================================================
# RESOLVE SSH KEYS PER PROVIDER
# ==============================================================================
KEY_APPSERVER=".vagrant/machines/appserver/${PROVIDER}/private_key"
KEY_WEB1=".vagrant/machines/webserver1/${PROVIDER}/private_key"
KEY_WEB2=".vagrant/machines/webserver2/${PROVIDER}/private_key"

# Validate keys exist
for key in "$KEY_APPSERVER" "$KEY_WEB1" "$KEY_WEB2"; do
  if [ ! -f "$key" ]; then
    echo "ERROR: SSH key not found: $key"
    echo "Make sure all VMs are up with 'vagrant status'"
    exit 1
  fi
done

SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=10"

echo "Deploying Application Containers to VMs..."

# Deploy Backend
echo "Deploying Backend to App Server (${BACKEND_IP})..."
ssh -i "$KEY_APPSERVER" $SSH_OPTS devops@${BACKEND_IP} '
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
ssh -i "$KEY_WEB1" $SSH_OPTS devops@${WEB1_IP} '
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
ssh -i "$KEY_WEB2" $SSH_OPTS devops@${WEB2_IP} '
  echo "Building frontend image..."
  cd /vagrant/frontend
  docker build -t vitals-frontend:latest .
  
  echo "Running frontend container..."
  docker stop vitals-frontend-app || true
  docker rm vitals-frontend-app || true
  docker run -d --name vitals-frontend-app --restart always -p 3000:3000 -e BACKEND_URL=http://192.168.56.14:8080 vitals-frontend:latest
'

echo "All applications deployed successfully!"