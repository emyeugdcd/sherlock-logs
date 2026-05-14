# Sherlock Logs (Monitoring & Logging Infrastructure)

This project builds upon the `automation-alchemy` infrastructure, integrating a robust observability stack. It adds a centralized **Monitoring VM** that hosts Prometheus, Grafana, and the ELK Stack (Elasticsearch, Logstash, Kibana) to provide real-time metrics and aggregated logging across all nodes.

## What's New Compared to Automation Alchemy?
1. **The Monitoring VM:** A 6th VM (`192.168.56.17`) configured with 3.5GB of RAM exclusively hosts our observability tools. Other VMs have been reconfigured with 1GB of RAM each to save resources while maintaining stability.
2. **Prometheus & Grafana:** Prometheus scrapes metrics from all VMs, and Grafana visualizes them on port `3000`.
3. **ELK Stack & Filebeat:** Filebeat is installed on all VMs, tailing `/var/log/*.log` and Docker container logs, shipping them to Logstash -> Elasticsearch -> Kibana (port `5601`).
4. **Agent Deployments:** Node Exporter is installed on all VMs (OS metrics), and cAdvisor is deployed via Docker on application servers (container metrics).
5. **Backend Application Instrumentation:** The Go backend was updated to import `github.com/prometheus/client_golang/prometheus`. It now exposes custom CPU/Memory gauges on the `/prometheus` endpoint. It also uses `logrus` for structured JSON logging.

## Requirements
- VirtualBox & Vagrant
- Ansible

## Installation & Deployment

Run the master playbook to configure the OS, UFW, WireGuard, Docker, and the Observability Stack.

```bash
./super_deploy.sh
```

## Manual Verification (How to Test)

1. **Verify the Applications:**
   - Frontend is accessible via Loadbalancer: `http://192.168.56.11`
   - Backend JSON API: `http://192.168.56.14:8080/metrics`
   - Backend Prometheus Exporter: `http://192.168.56.14:8080/prometheus`

> From down here, the detailed steps for the below verification steps can be found in the `docs/ui-guide.md` file. However, these are the quick steps if you want to verify them quickly.

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
