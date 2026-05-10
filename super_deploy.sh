#!/bin/bash
echo "Starting Automation Alchemy (One-Click Deploy)..."

echo "Booting 6-Node Infrastructure..."
vagrant up

echo "Installing Core Infrastructure..."
ansible-playbook -i inventory.ini setup.yml -e "ansible_user=vagrant devops_password=SuperSecurePassword123!" || ansible-playbook -i inventory.ini setup.yml -e "ansible_user=devops devops_password=SuperSecurePassword123!"

echo "Deployment Scripts Executed!"
echo "The GitHub Actions CI/CD will now handle the application deployment when code is pushed!"
echo "Triggering local deployment since GitHub Actions cannot reach local VMs..."
./deploy_apps.sh
