# Project Walkthrough: What happened in Automation Alchemy

## Infrastructure:
5-NODE NETWORK — 192.168.56.0/24
loadbalancer
192.168.56.11
Nginx, 1 vCPU — public entry point

webserver1
192.168.56.12
Docker, Node.js frontend, 1 vCPU

webserver2
192.168.56.13
Docker, Node.js frontend, 1 vCPU

appserver
192.168.56.14
Docker, Go backend, 1GB RAM

backup
192.168.56.15
Weekly cron tar backup

## Traffic Flow
User -> Load Balancer (192.168.56.11:80)
Load Balancer -> Round Robin -> Web Server 1 & 2 (192.168.56.12, 192.168.56.13)
Web Server -> Proxy -> App Server (192.168.56.14)

## Deploy Flow:

SUPER_DEPLOY.SH — WHAT HAPPENS IN ORDER
1
vagrant up
Vagrant reads Vagrantfile, boots 6 VMs in VMware Fusion, assigns IPs, runs guest additions. Takes several minutes on first run. Subsequent runs are fast if VMs already exist.
2
ansible-playbook -e "ansible_user=vagrant"
Tries to connect as vagrant (the default user Vagrant creates). On a fresh VM this works. Runs all tasks in setup.yml across all 6 hosts simultaneously.
3
|| fallback to ansible_user=devops
If the first run fails (because vagrant SSH was locked out in a previous partial run), retries as devops. This covers re-runs and partial failures.
4
Prints Jenkins URL
Points you to http://192.168.56.16:8080 — the Jenkins dashboard. This is the original intended workflow before I switched to GitHub Actions.

## GitHub Actions Flow:

test_and_quality_gates
↓
build_artifacts
↓
deploy_backend (single job, appserver)
↓
deploy_frontend (matrix: webserver1 + webserver2 in parallel)
↓
notify (always runs, checks both results)

