# Advanced Alerting: Prometheus & Alertmanager 

## 1. What is PromQL?
PromQL (Prometheus Query Language) is the math language used to query metrics. 
Instead of a simple "CPU > 80", PromQL allows us to do complex trends.

**Example of an Advanced PromQL Alert:**
*Instead of alerting if an error happens, alert if the ERROR RATE is higher than 5% of the TOTAL REQUEST RATE.*
```promql
  rate(http_requests_total{status="500"}[5m]) 
  / 
  rate(http_requests_total[5m]) > 0.05
```

## 2. What is Alertmanager?
Prometheus itself just calculates the PromQL math. It doesn't know how to send a Slack message or an Email. 
If Prometheus calculates that an alert is firing, it sends a signal to **Alertmanager**. 
Alertmanager is a separate application that handles "Escalation" and "Throttling".

* **Throttling:** If 50 web servers all crash at exactly the same time, we don't want 50 Slack messages. Alertmanager groups them into 1 single Slack message that says "50 servers are down".
* **Escalation:** Send the alert to Slack. If nobody clicks "Acknowledge" in 15 minutes, send an SMS to the manager via PagerDuty.

## 3. How to implement it (Tutorial)
To set this up in our project, we would need to do 3 things:

**Step A: Add Alertmanager to `docker-compose.yml`**
Add a new container to our monitoring stack:
```yaml
  alertmanager:
    image: prom/alertmanager
    ports:
      - 9093:9093
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml
```

**Step B: Tell Prometheus about Alertmanager**
Edit `prometheus.yml` to include:
```yaml
alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']

rule_files:
  - "alert_rules.yml"
```

**Step C: Write our `alert_rules.yml`**
Create a new file with our actual alert math:
```yaml
groups:
- name: advanced_alerts
  rules:
  - alert: HighErrorRate
    expr: rate(http_requests_total{status="500"}[5m]) / rate(http_requests_total[5m]) > 0.05
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "High error rate detected!"
```

**Summary:** 
For a beginner or personal project like this, I think sticking to Grafana Alerts is perfectly fine and satisfies the core requirements. However, to score for extras, I need to use Alertmanager and PromQL. Still, it is good to know about setting up Alertmanager and writing native PromQL rules as it is how it is done in heavy production environments!
