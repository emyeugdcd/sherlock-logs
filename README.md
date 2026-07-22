<div align="center">
  <h1>Sherlock Logs</h1>
  <p><strong>A scrub nurse running on Cloud: Chapter 4 of 8. A foundational DevOps journey into Infrastructure as Code, Linux Administration, and Server Security, with end-to-end automation using Github Actions (CI/CD) and Docker. But wait..., now we have a whole new VM for monitoring & logging for our application!</strong></p>
</div>

--- 

# Project Overview
Welcome to **Sherlock Logs**! This is the fourth project of the 8-project DevOps module. Everything is documented clearly in the README, including what this project is about, how it connects to the previous projects, and how to test it yourself. I've also included a docs/ folder with my learning notes if you want to go deeper on any concept. 

Here's a summary of all previous projects so you have context for what you're reviewing:

**Project 1 - Server Sorcery**: I have built a network of 4 virtual machines simulating real-life infrastructure: a load balancer, two web servers, an app server. 
- Each VM is automatically installed with the necessary software, security hardening (UFW, Fail2Ban, SSH restrictions), and networking configuration using Ansible.

Link to project 1: [https://github.com/emyeugdcd/server-sorcery-101](https://github.com/emyeugdcd/server-sorcery-101)

**Project 2 - Infrastructure Insight**: with the 4 VMs of the first project running, I then built a surgical-theatre-themed system metrics dashboard (well since I am a surgical nurse haha). The backend is a Go application running on the appserver: it reads raw performance data directly from the appserver's Linux kernel's virtual filesystem and exposes that data as a JSON API. The frontend is a Node.js application running on both webservers: it fetches from the backend API and renders the metrics as a live Medical Dashboard in the browser. When you visit http://192.168.56.11/, the loadbalancer routes your request to either webserver1 or webserver2. Backend and Frontend applications are deployed by Docker.

Link to project 2: [https://github.com/emyeugdcd/infrastructure-insight](https://github.com/emyeugdcd/infrastructure-insight)

**Project 3 - Automation Alchemy**: Automates everything from the first two projects into a single command: ./super_deploy.sh. Additionally, a GitHub Actions CI/CD pipeline is configured so that whenever we make changes to the backend and frontend application codes and push them, the corresponding running Docker containers will be destroyed and built again. That is what CI/CD means: continuous integration and continuous delivery

Link to project 3: [https://github.com/emyeugdcd/automation-alchemy](https://github.com/emyeugdcd/automation-alchemy)

**Project 4 - Sherlock Logs**: This project builds upon the `automation-alchemy` infrastructure, integrating a robust observability stack. It adds a centralized **Monitoring VM** that hosts Prometheus, Grafana, and the ELK Stack (Elasticsearch, Logstash, Kibana) to provide real-time metrics and aggregated logging across all nodes.x

## What's New Compared to Automation Alchemy?
1. **The Monitoring VM:** A 6th VM (`192.168.56.17`) configured with 3.5GB of RAM exclusively hosts our observability tools. Other VMs have been reconfigured with 1GB of RAM each to save resources while maintaining stability.
2. **Prometheus & Grafana:** Prometheus scrapes metrics from all VMs, and Grafana visualizes them on port `3000`.
3. **ELK Stack & Filebeat:** Filebeat is installed on all VMs, tailing `/var/log/*.log` and Docker container logs, shipping them to Logstash -> Elasticsearch -> Kibana (port `5601`).
4. **Agent Deployments:** Node Exporter is installed on all VMs (OS metrics), and cAdvisor is deployed via Docker on application servers (container metrics).
5. **Backend Application Instrumentation:** The Go backend was updated to import `github.com/prometheus/client_golang/prometheus`. It now exposes custom CPU/Memory gauges on the `/prometheus` endpoint. It also uses `logrus` for structured JSON logging.
6. Added SLIM_MODE and step-by-step instructions for running the project in SLIM_MODE. SLIM MODE is used to save RAM if host machine's RAM is under 8GB of RAM (limited memory)
7. Added VM_Provider so now project can be tested on different OS.

## Requirements & Setup
 
### RAM Requirements
 
| Mode | VMs | Total VM RAM | Recommended Host RAM |
|------|-----|-------------|----------------------|
| Normal | 6 VMs (incl. backup) | ~9.5 GB | 16 GB |
| SLIM_MODE | 5 VMs (no backup) | ~6.5 GB | 8 GB |
 
> **On 8GB RAM?** Use SLIM_MODE — see instructions below.
 
---
 
### Option A — macOS (VMware Fusion) — Original Setup
 
This is the environment the project was developed on.
 
**Install dependencies:**
 
```bash
brew install hashicorp/tap/vagrant
vagrant plugin install vagrant-vmware-desktop
```
 
Also install [VMware Fusion Pro](https://www.vmware.com/products/fusion.html) (free for personal use via Broadcom) and the [Vagrant VMware Utility](https://developer.hashicorp.com/vagrant/docs/providers/vmware/vagrant-vmware-utility).
 
**Run:**
 
```bash
./super_deploy.sh
```
 
---
 
### Option B — Linux or Windows (VirtualBox)
 
**Install dependencies:**
 
- [Vagrant](https://developer.hashicorp.com/vagrant/downloads)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html) (Linux/macOS only — Windows users should run Ansible from WSL2)
**Run:**
 
```bash
VAGRANT_DEFAULT_PROVIDER=virtualbox ./super_deploy.sh
```
 
Or set the provider explicitly when bringing VMs up:
 
```bash
vagrant up --provider=virtualbox
```
 
---
 
### SLIM_MODE — For hosts with 8GB RAM
 
SLIM_MODE reduces memory allocation across all VMs and **removes the backup VM** entirely. Total allocated RAM drops from ~9.5GB to ~6.5GB, leaving enough headroom for the host OS.
 
**RAM comparison:**
 
| VM | Normal | SLIM_MODE |
|----|--------|-----------|
| loadbalancer | 1024 MB | 640 MB |
| webserver1 | 1024 MB | 768 MB |
| webserver2 | 1024 MB | 768 MB |
| appserver | 1024 MB | 768 MB |
| monitoring | 3584 MB | 3072 MB |
| backup | 1024 MB | ❌ removed |
| **Total** | **9.5 GB** | **~6.5 GB** |
 
#### Observability & Vagrant Enhancements:
- **Dynamic Provider Auto-Detection**: Both `./super_deploy.sh` and `./deploy_apps.sh` auto-detect the active Vagrant provider (`vmware_desktop`, `vmware_fusion`, or `virtualbox`) and automatically configure the correct SSH private keys.
- **Dynamic JVM Heap Scaling**: Using Jinja2 templates, Elasticsearch and Logstash heap allocations are automatically optimized on the monitoring VM:
  - **Normal**: Elasticsearch = 1GB heap, Logstash = 512MB heap.
  - **SLIM_MODE**: Elasticsearch = 512MB heap, Logstash = 256MB heap (preventing VM Out-of-Memory crashes).
- **Dynamic Prometheus Scraping**: The `backup` VM target is automatically omitted from Prometheus scraping in SLIM_MODE to avoid false-positive unreachable alerts.
- **Sub-Millisecond Backend Metrics API**: The Go backend `/metrics` endpoint caches CPU usage updates in a background thread-safe goroutine using a read-write mutex (`sync.RWMutex`). This reduces API response latency from a blocking 500ms to less than 1ms.
 
**How to Run in SLIM_MODE:**
 
**On macOS (VMware):**
 
```bash
SLIM_MODE=true ./super_deploy.sh
```
 
**On Linux / Windows (VirtualBox):**
 
```bash
SLIM_MODE=true VAGRANT_DEFAULT_PROVIDER=virtualbox ./super_deploy.sh
```
 
Or step by step manually:
 
```bash
# 1. Bring up VMs
SLIM_MODE=true vagrant up
 
# 2. Run Ansible provisioning (replace <provider> with virtualbox, vmware_fusion, or vmware_desktop)
ansible-playbook -i inventory_slim.ini setup.yml \
  -e "ansible_user=vagrant devops_password=SuperSecurePassword123! ansible_become_pass=SuperSecurePassword123! slim_mode=true vagrant_provider=<provider>"
 
# 3. Deploy application containers
./deploy_apps.sh
```
 
---
 
## Accessing the Stack
 
Once deployed, all services are available at the following addresses:
 
| Service | URL | Notes |
|---------|-----|-------|
| Application (via load balancer) | http://192.168.56.11 | Nginx routes to webserver1/2 |
| Grafana | http://192.168.56.17:3000 | Default login: admin / admin |
| Kibana | http://192.168.56.17:5601 | ELK log visualisation |
| Prometheus | http://192.168.56.17:9090 | Raw metrics & query UI |
| Netdata (webserver1) | http://192.168.56.12:19999 | Real-time per-VM metrics |
| Netdata (webserver2) | http://192.168.56.13:19999 | Real-time per-VM metrics |
| Netdata (appserver) | http://192.168.56.14:19999 | Real-time per-VM metrics |

## Manual Verification (How to Test)

1. **Verify the Applications:**
   - Frontend is accessible via Loadbalancer: `http://192.168.56.11`
   - Backend JSON API: `http://192.168.56.14:8080/metrics`
   - Backend Prometheus Exporter: `http://192.168.56.14:8080/prometheus`

> From here onwards, the detailed steps for the below verification steps can be found in the `docs/ui-guide.md` file. However, these are the quick steps if you want to verify them quickly.

2. **Verify Grafana (Metrics):**
   - URL: `http://192.168.56.17:3000`
   - Login: `admin` / `admin`
   - Add a Prometheus Data Source: URL = `http://prometheus:9090`
   - You can create dashboards mapping CPU, Memory, and cAdvisor container stats.

3. **Verify Kibana (Logs):**
   - URL: `http://192.168.56.17:5601`
   - Go to Stack Management -> Data Views.
   - Create a data view matching `logstash-*`.
   - Go to "Discover" and you will see real-time logs from Filebeat streaming from your App and Web servers!

4. **Verify Prometheus (Scraping):**
   - URL: `http://192.168.56.17:9090`
   - Go to Status -> Targets. All endpoints (Node Exporter, cAdvisor, Go Backend) should show as `UP`.

## Documentation

- In the /docs folder, you will find many guides and studying materials I created for this project for future reference. For example, I have created a detailed guide on how to build and use **GitHub Actions** (which is a CI/CD tool) from scratch: **[github-actions-guide.md](https://github.com/emyeugdcd/sherlock-logs/blob/main/docs/github-actions-guide.md)**. You will also find other study guides in the /docs folder such as ui-guide.md. 

- If you feel so overwhelmend with all the information, especially if you are not very familiar with DevOps concepts yet, I suggest you start from the /checkpoint directory within the /docs directory. Those are the questions I asked AI to prepare for me to test my knowledge regarding all the concepts and knowledges I have learnt during the 4 projects to ensure that I have fully understood them. I believe they will help you too. They are arranged in a way that you can go through them topic by topic, which is great for systematic learning. Don't worry if you cannot understand some of the questions or the answers at first: we can discuss them together in the review call

- In the /docs I also included the how-to-test.md file, which contains all the testing requirements for this project. I then have prepared a learning-notes.md file to answer and help you test all the requirements step-by-step.
   