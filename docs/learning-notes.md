# Sherlock Logs: Tutorial & Quick Study Guide

I compiled and prepared this study guide to help myself to understand the new concepts and terminologies involved. By now, we all know that Sherlock Logs is basically Automation Alchemy, but enhanced with observability tools like the ELK stack and Prometheus + Grafana. This document is divided into two parts:
1. **The Mental Models**: A quick, jargon-free tutorial on Prometheus, Grafana, and the ELK stack.
2. **The `how-to-test.md` Checklist**: Detailed answers and explanations for every requirement in the testing rubric. I used this as a basis for studying before I myself can check off the checklist of the how-to-test.md file.

---

## Part 1: The Mental Models (Tutorial & Quick Guide)
### 1. Prometheus (The Metric Scraper)
* **What it is:** A time-series database. It stores numbers that change over time (e.g., CPU %, memory bytes, number of HTTP requests).
* **How it works:** It uses a **Pull Model**. It has a list of IP addresses. Every 15 seconds, it knocks on the door of those IPs at a specific path (like `http://192.168.56.12:9100/metrics`) and says, "Give me your current numbers!"
* **In this project:** It scrapes the VMs (via Node Exporter), the Docker containers (via cAdvisor), and the Go backend.
* **In Production:** It is the industry standard for Kubernetes. It constantly scrapes thousands of microservices and fires alerts to PagerDuty if metrics cross a red line.

### 2. Grafana (The Visualization Layer)
* **What it is:** A beautiful dashboarding tool. It doesn't store any data itself. 
* **How it works:** You connect it to a "Data Source" (like Prometheus). When you open a dashboard, Grafana asks Prometheus for the numbers and draws pretty graphs.
* **In this project:** You use it to build dashboards for VM Performance, Docker Containers, and Application.
* **In Production:** It is the "Single Pane of Glass." Operations teams usually have massive Grafana dashboards on TVs in their offices to see the health of the entire company at a glance.

### 3. The ELK Stack (The Log Detectives)
While Prometheus handles **Metrics** (numbers), ELK handles **Logs** (text). ELK stands for **E**lasticsearch, **L**ogstash, and **K**ibana.

* **Elasticsearch (The Database):** A massive, RAM-hungry database specifically optimized for searching text extremely fast. 
* **Logstash / Filebeat (The Pipes):** Log files live on individual VMs. Filebeat sits on the VM, reads the log file, and ships the text over the network. Logstash acts as a filter in the middle—it can read a messy log line, extract the IP address and error code, format it neatly as JSON, and push it into Elasticsearch.
* **Kibana (The UI):** Grafana is to Prometheus what Kibana is to Elasticsearch. Kibana is the web interface we use to search for logs. If a user says "My payment failed at 2:05 PM", we open Kibana, type "payment error", and Elasticsearch instantly finds the log.

---

## Part 2: Answers to `how-to-test.md`

I used this section to study for deeper understanding of the project requirements, also to prove that I understood and could implement these concepts.

### Architecture & Theory

**1. Difference between push-based and pull-based monitoring? Why does Prometheus use pull?**
* **Push:** Every server runs a script that sends its metrics to a central monitoring server. (e.g., StatsD, Telegraf).
* **Pull:** The central monitoring server (Prometheus) reaches out to the servers to grab the metrics.
* **Why Pull?** In a distributed architecture, if a server crashes in a push model, it just stops sending data. You might not notice immediately. In a pull model, Prometheus tries to scrape the server, gets a "Connection Refused", and instantly knows the server is dead. Pull also prevents the central server from being DDoS'd by thousands of agents pushing data at the same time.

**2. Architecture of the ELK stack and component roles?**
* **Elasticsearch:** The storage and search engine. Indexes log data for lightning-fast querying.
* **Logstash:** The data processing pipeline. Ingests data from multiple sources, transforms it (parsing messy text into structured JSON), and sends it to Elasticsearch.
* **Kibana:** The visualization and exploration UI. Used to search the logs stored in Elasticsearch and build log-based dashboards.

**3. Advantages/Disadvantages of Prometheus over Nagios/Zabbix?**
* **Advantages:** Prometheus uses a dimensional data model (key-value labels) which is infinitely more flexible than Nagios's rigid host/service model. It is designed for dynamic cloud environments where servers spin up and down constantly. PromQL is an incredibly powerful math language for metrics.Dimensional data modeling is widely considered superior to normalized host/service (operational) models for analytics and reporting because it is designed specifically for speed, usability, and business context, rather than transaction processing. They have superior query performance, simple to use, and are designed to handle historical data gracefully, allowing for tracking changes over time
* **Disadvantages:** Prometheus is strictly for metrics, not logs. It also does not offer long-term durable storage out-of-the-box (it drops old data) unless paired with a tool like Thanos.

**6. Benefits of Grafana over Kibana or Datadog?**
* **Over Kibana:** Grafana is purpose-built for time-series metrics from dozens of different databases (Prometheus, MySQL, InfluxDB). Kibana is tightly coupled to Elasticsearch and is better for log text search.
* **Over Datadog:** Grafana is open-source and free to host yourself. Datadog is a paid, proprietary SaaS product that can get extremely expensive at scale.

### Configuration & Troubleshooting

**4. How to adjust the Prometheus scrape interval?**
I edited the `prometheus.yml` configuration file. Under `global:`, I set `scrape_interval: 15s`. We can also override this for specific targets in the `scrape_configs` block.

**5. Common issues with Node Exporter / cAdvisor setup?**
* **Firewall blocks:** Forgetting to open port `9100` (Node Exporter) or `8081` (cAdvisor) in UFW.
* **Docker Socket:** cAdvisor needs to read the Docker daemon to get container metrics. If `/var/run:/var/run:ro` is not mounted in its `docker run` command, it will fail.
* **Incorrect IPs:** Prometheus trying to scrape the wrong IP because `/etc/hosts` isn't configured correctly.

**7. How to expose application metrics using Prometheus client libraries?**
I imported a library (like `prometheus/client_golang` for Go). I defined a metric variable, like a `Counter` for HTTP requests. Every time my backend application handles a request, I call `counter.Inc()`. Finally, I register a `/metrics` HTTP route that the library automatically serves in the Prometheus text format.

**9. How to handle Logstash format inconsistencies and parsing errors?**
Logstash uses a filter called `Grok` to parse text. If a log line doesn't match the Grok pattern, Logstash tags it with `_grokparsefailure`. To handle this, we can write conditional logic in the Logstash pipeline (`if "_grokparsefailure" in [tags] { ... }`) to either apply a fallback pattern or dump the raw log into a special "unparsed" index so it doesn't break the main data.

**12. Troubleshooting common issues with metric collection?**
Always check the Prometheus "Targets" page (`http://<prometheus-ip>:9090/targets`). It will tell you exactly why a scrape is failing. Common errors are `connection refused` (firewall or service down) or `context deadline exceeded` (network latency).

**13. Creating long-term retention policies?**
Prometheus stores data on disk. You set retention using the command-line flag `--storage.tsdb.retention.time=15d` (keep data for 15 days). For Elasticsearch, you use "Index Lifecycle Management" (ILM) to automatically delete logs older than 30 days to prevent your hard drive from filling up.

**15. Handling CI/CD dynamic agent configuration?**
CI/CD pipeline (or Ansible) should use environment variables or templating. For example, Filebeat needs to know the IP of Logstash. Instead of hardcoding it, Ansible injects the IP into `filebeat.yml` based on the environment it's deploying to (dev vs prod).

### Alerting

**16 & 18. Avoiding alert fatigue and fine-tuning thresholds?**
Alert fatigue happens when on-call engineers get pinged so often for false alarms that they start ignoring them. To fix this:
* **Use duration (`for: 5m`):** Don't alert the second CPU hits 90%. Wait 5 minutes to ensure it's a real problem, not just a temporary spike.
* **Actionable alerts only:** Don't page someone at 3 AM because "Disk is at 70%". Page them if "Disk will be 100% full in 4 hours based on current growth rate."

**17. Logstash sending alert notifications?**
Logstash isn't typically the best tool for sending alerts (Prometheus Alertmanager is better), but we can do it by adding an `output` plugin in Logstash. For example, if Logstash matches a log with the word `FATAL`, we can route it to an `http` output plugin that triggers a Slack webhook.

**28. Using PromQL for advanced alerts (Combinations/Trends)?**
PromQL allows math. Instead of alerting if error count is > 10, we can alert if the *error rate* divided by the *total request rate* is > 5%. 
Example: `rate(http_requests_total{status="500"}[5m]) / rate(http_requests_total[5m]) > 0.05`

**29. External platform notifications and throttling?**
Prometheus sends alerts to **Alertmanager**. Alertmanager handles routing the alert to Slack/Email/PagerDuty. It handles "throttling" (grouping multiple similar alerts into one message) and "escalation" (if the primary engineer doesn't acknowledge the alert in 15 minutes, page the manager).

---

## 🚀 How to use this guide
Read this through a few times. Don't try to memorize it—try to understand the *why*. When you are writing your Ansible tasks to deploy these tools, refer back to the Mental Models to remind yourself what the tool is actually supposed to be doing!
