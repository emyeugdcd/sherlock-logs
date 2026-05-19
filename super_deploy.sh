#!/bin/bash
set -e  # Exit immediately on error

echo "Starting Virtual Infrastructure Machines Deployment (One-Click Deploy)..."

SLIM_OPT="false"
INVENTORY="inventory.ini"
BOOT_MSG="Booting 6-Node Infrastructure..."

if [ "$SLIM_MODE" = "true" ]; then
  SLIM_OPT="true"
  INVENTORY="inventory_slim.ini"
  BOOT_MSG="Booting 5-Node (SLIM MODE) Infrastructure..."
fi

echo "$BOOT_MSG"
# If default provider is set, use it. Otherwise, let Vagrant choose.
vagrant up

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
  exit 1
fi

echo "Detected provider: ${PROVIDER}"
echo "Installing Core Infrastructure via Ansible..." # it will take 15-20 minutes

ansible-playbook -i "$INVENTORY" setup.yml -e "ansible_user=vagrant devops_password=SuperSecurePassword123! ansible_become_pass=SuperSecurePassword123! slim_mode=$SLIM_OPT vagrant_provider=$PROVIDER" || \
ansible-playbook -i "$INVENTORY" setup.yml -e "ansible_user=devops devops_password=SuperSecurePassword123! ansible_become_pass=SuperSecurePassword123! slim_mode=$SLIM_OPT vagrant_provider=$PROVIDER"

echo "Deployment Scripts Executed!" # it will take 1 minute
echo "The GitHub Actions CI/CD will now handle the application deployment when code is pushed!"
echo "Triggering local deployment since GitHub Actions cannot reach local VMs..."
./deploy_apps.sh
