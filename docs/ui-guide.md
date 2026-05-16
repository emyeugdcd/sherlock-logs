# The Web UI Beginner's Guide 🖥️

This is the first project among the four projects that actually uses a web GUI! So far we have been staring at the terminal for the last 3 projects. But the beauty of Observability tools is their web interfaces! Here is a guide on how to use them and how to set up alerts.

*Assuming you ran `./super_deploy.sh`, all these tools are running on your `monitoring` VM at IP `192.168.56.17`.*

## 1. Prometheus (The Raw Metrics)
**URL:** `http://192.168.56.17:9090`
* **What to do here:** Prometheus has a very basic UI. You don't use this to look at pretty graphs. You use this to **Debug**.
* **Check Targets:** Click on **Status** > **Targets** at the top. This is the most important page. It shows you every server Prometheus is trying to scrape. If a server is down, it will be red here.
* **Test PromQL:** In the main search bar, you can type a metric like `node_cpu_seconds_total` and click Execute to see the raw data coming in.

## 2. Grafana (The Pretty Graphs & Alerts)
**URL:** `http://192.168.56.17:3000` (Default login is usually `admin` / `admin`)
* **What to do here:** This is where you build your dashboards. 
* **Data Sources:** First, go to Settings > Data Sources, add "Prometheus", and point it to `http://192.168.56.17:9090` (or `http://localhost:9090` if they are in the same docker-compose network).
* **Dashboards:** Click the '+' icon to create a dashboard. You can add a panel, select your Prometheus data source, and write a PromQL query to draw a graph of CPU usage.
Here is a really useful link about creating Grafana dashboards:
https://medium.com/@dineshmurali/introduction-to-monitoring-with-prometheus-grafana-ea338d93b2d9

### SETTING UP ALERTS IN GRAFANA
I'm so happy that I don't *have* to write alerts in YAML code! Modern Grafana has a built-in Alerting UI that is much easier for beginners.
1. In Grafana, click the **Alerting** (Bell icon) on the left menu.
2. Click **Create Alert Rule**.
3. **Condition:** You select a metric (like CPU usage) and set a threshold (e.g., `IS ABOVE 80`).
4. **Duration:** You set the "Evaluate for" field to `5m`.
5. **Notifications:** You tell it where to send the alert (e.g., an Email or a Slack channel).

*For the project, you can literally just create these alerts inside the Grafana UI to pass the requirements!*

## 3. Kibana (The Log Explorer)
**URL:** `http://192.168.56.17:5601`
* **What to do here:** This is where you search your text logs.
* **Data Views / Index Patterns:** The first time you log in, Kibana won't know what data to show. Go to Stack Management > Index Patterns (or Data Views) and create a pattern called `logstash-*` or `filebeat-*`. This tells Kibana to look at the data being sent by your VMs.
* **Discover:** Click the **Discover** compass icon on the left menu. This is your main search engine. You will see a live stream of every log line from every VM. You can search for things like `error` or filter by `host.name: webserver1`.

## 4. Logstash (No UI!)
Logstash is a pure background process. It does not have a web UI! You configure it purely through the `logstash.conf` file, and it quietly processes data in the background and sends it to Elasticsearch.
