#!/bin/bash
echo "Starting Virtual Infrastructure Machines Deployment (One-Click Deploy)..."

echo "Booting 6-Node Infrastructure..." # it will take 15-20 minutes
vagrant up

echo "Installing Core Infrastructure..." # it will take 15-20 minutes
ansible-playbook -i inventory.ini setup.yml -e "ansible_user=vagrant devops_password=SuperSecurePassword123! ansible_become_pass=SuperSecurePassword123!" || ansible-playbook -i inventory.ini setup.yml -e "ansible_user=devops devops_password=SuperSecurePassword123! ansible_become_pass=SuperSecurePassword123!"

echo "Deployment Scripts Executed!" # it will take 1 minute
echo "The GitHub Actions CI/CD will now handle the application deployment when code is pushed!"
echo "Triggering local deployment since GitHub Actions cannot reach local VMs..."
./deploy_apps.sh
