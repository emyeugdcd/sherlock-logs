1. What is Prometheus and what problem does it solve?

Prometheus is an open-source monitoring system and time series database. It solves the problem of tracking how numeric values change over time across distributed infrastructure: things like CPU usage, memory, request rates, error counts. Without it you'd have no historical visibility into your system's health, only what's happening right now.

2. Explain the pull model. How is it different from push-based monitoring?

In a pull model, Prometheus is in charge: it sends an HTTP GET to each target's /metrics endpoint on a schedule (every 15 seconds by default) and collects whatever is there. In a push model, each server is responsible for sending its own metrics to a central collector. Pull is easier to reason about: Prometheus knows exactly what it's collecting and when, and if a target goes silent you immediately know it's down. Push systems can have timing issues and it's harder to detect a dead server.

3. What is an exporter? Give two examples and what they collect.

An exporter is a small process that runs alongside something you want to monitor. It translates that thing's internal state into Prometheus text format and exposes it at /metrics so Prometheus can scrape it. 
Node Exporter runs on Linux VMs and exposes OS-level metrics — CPU, memory, disk, network — by reading from /proc and /sys. 
cAdvisor runs on Docker hosts and exposes per-container metrics — CPU usage per container, memory limits, restart counts — by talking to the Docker daemon.

4. What does a Prometheus metrics endpoint look like? What are the four metric types?

It's plain text served over HTTP. Each metric has a name, optional labels in curly braces, and a value:
http_requests_total{method="GET",status="200"} 1234
process_memory_bytes 52428800
request_duration_seconds{quantile="0.99"} 0.045

The four types are: 
Counter (only goes up, like total requests): 
Gauge (can go up or down, like current memory usage): 
Histogram (samples observations into buckets, like request duration): 
Summary (similar to histogram but calculates quantiles client-side).

5. What is PromQL? Give an example of a useful query.

PromQL is Prometheus's query language for selecting and aggregating time series data. A simple useful example:
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
This calculates CPU usage percentage across all instances by looking at the rate of idle CPU ticks over a 5 minute window and inverting it. You'd use this in a Grafana dashboard panel.

6. What is an alert in Prometheus and how does it work?
    
An alert is a PromQL expression that Prometheus evaluates on a schedule. If the expression is true for longer than a defined duration, Prometheus fires the alert to Alertmanager, which then routes it to a notification channel like Slack, email, or PagerDuty. Example rule:
alert: HighCPU
expr: cpu_usage_percent > 80
for: 5m
labels:
severity: warning
annotations:
summary: "CPU above 80% for 5 minutes on {{ $labels.instance }}"
The "for: 5m" means the condition must be continuously true for 5 minutes before firing — this prevents false alarms from brief spikes.

7. What is the difference between Metrics (Prometheus) and Logs (Elasticsearch/Filebeat)?

Metrics are numeric aggregations measured over time (like CPU %, memory usage, or error rates). They tell you *if* there is a problem and *when* it happened. Logs are discrete events or text strings (like error messages, stack traces, or user actions). They tell you *why* the problem happened. In a healthy observability flow, you look at your Prometheus metrics/dashboards first to spot a spike, then search your logs around that exact timestamp to find the root cause.

8. Why is centralized logging important in a distributed multi-server architecture?

In a multi-server setup (like having webserver1, webserver2, appserver, etc.), if a user reports an error, you don't know which server handled their request. Without centralized logging, you would have to SSH into each server individually and `tail`/`grep` through log files to find the error. Centralized logging aggregates logs from all servers into one single searchable database (like Elasticsearch) so you can query logs across your entire infrastructure from one dashboard (like Kibana).

9. What is the ELK/EFK stack, and what role does each component play?

ELK stands for Elasticsearch, Logstash, and Kibana (EFK replaces Logstash with Fluentd, or in modern setups, just uses Filebeat). 
- **Elasticsearch**: The search and analytics engine. It acts as the database where all logs are stored and indexed so they can be searched lightning-fast.
- **Logstash / Filebeat**: The shipper/processor. It runs as an agent on the individual servers, reads the local log files, and ships them over the network to Elasticsearch.
- **Kibana**: The visualization layer. It is the web UI you log into to run search queries on the logs in Elasticsearch and build visual dashboards.