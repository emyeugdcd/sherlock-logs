sherlock logs 🕵️
The situation 👀
Your automation skills have significantly improved the efficiency of your startup's operations. The CTO is thrilled with the progress but has identified a new challenge. As the company's infrastructure grows and becomes more complex, it's becoming increasingly difficult to monitor system health, track performance, and troubleshoot issues across all the distributed components.
Monitoring and logging are vital in the modern IT industry, ensuring system reliability, performance, and security. Effective monitoring provides real-time insights into infrastructure and application health, enabling proactive issue resolution. Logging offers detailed historical records essential for debugging, auditing, and compliance. Together, they enable continuous visibility and control over complex environments, enhancing operational efficiency, reducing downtime, and supporting data-driven decision-making, ultimately driving business success.
Functional requirements 📋
For this project, you'll be using industry-leading tools: Prometheus and Grafana for monitoring, and the ELK stack for logging.
Setting Up Monitoring and Logging 📊📝
As with any critical tools, it's better to have them running separately from other logic. Therefore, spin up a new VM which will bear the duty of monitoring and logging your environment and set up the following:
Monitoring:
Prometheus to collect metrics from all sources.
Assisting tools like Node Exporter, cAdvisor, and/or others to send relevant metrics to Prometheus.
Rewrite Existing Infrastructure Metrics Application to expose its metrics in a format that Prometheus can scrape. This involves adding a metrics endpoint to the application using Prometheus client libraries.
Grafana to visualize metrics from Prometheus.
For monitoring, the goal is to provide real-time visibility into the performance and health of all system components, including VMs, Docker containers, and the application.
Logging:
Elasticsearch to store and index logs.
Logstash to collect and process logs from various sources.
Filebeat or similar log shipper to collect and forward logs to Logstash.
Rewrite Existing Infrastructure Metrics Application to send its logs to Logstash. This involves configuring the application to use a logging framework that supports sending logs to Logstash, or using Filebeat to collect and forward the application's logs.
Kibana to visualize logs from Elasticsearch.
For logging, the goal is to centralize and analyze logs from all parts of the system, enabling efficient troubleshooting, security monitoring, and historical analysis of system behavior.
Creating Dashboards 📈
There's not much use in collecting metrics and logs if you can't visualize and analyze them effectively. Dashboards provide a powerful way to gain insights into your system's performance and health, enabling you to make informed decisions and quickly identify issues.
At minimum, you will have to create the dashboards listed below, but you are encouraged to include any additional metrics/logs as you see fit to enhance your monitoring and logging capabilities.
Grafana
VM Performance Dashboard: CPU usage, Memory utilization, Disk I/O, Network traffic
Docker Container Dashboard: Container health, CPU and memory usage, Restart counts
Application Performance Dashboard: Response times, Error rates, 1 custom application metric
Kibana
System Logs Dashboard: system logs from all VMs (e.g., syslog, dmesg)
Application Logs Dashboard: application-specific logs (e.g., error logs, access logs)
Docker Logs Dashboard: Docker container logs (e.g., stdout, stderr outputs)
Creating Alerts 🚨
Getting alerted at the earliest sign of potential issues is crucial for mitigating problems before they escalate into critical failures.
Set up the alerts listed below, but as before, you are encouraged to add as many additional alerts as you see fit to enhance your monitoring capabilities.
VM-related alerts:
CPU usage exceeds 80% for more than 5 minutes
Available disk space falls below 20%
Memory usage exceeds 90% for more than 5 minutes
Docker-related alerts:
Container restarts more than 3 times in 15 minutes
Container memory usage exceeds 80% of its limit
General infrastructure alerts:
Any VM becomes unreachable
Elasticsearch cluster status changes to yellow or red
Automation and Integration 🤖
As with previous tasks, automation is key. Ensure that the setup of your new monitoring and logging VM is incorporated into your existing automation flow. Additionally, make sure that your CI/CD pipeline is updated to include the deployment of any necessary monitoring or logging agents to new instances as they're created.
Expected outcome 🎯
By the end, you should have a fully functional monitoring and logging system that allows you to:
View real-time performance metrics across your system.
Quickly identify and troubleshoot issues.
Analyze historical performance data.
Receive timely alerts for critical issues.
Extra requirements 📚
Advanced Alerting Rules: Configure advanced alerting rules that go beyond simple threshold-based alerts. This can include trend-based alerts (e.g., a steady increase in CPU usage over time) or alerts based on combinations of metrics (e.g., high CPU usage and low available memory simultaneously).
Extended Notification: Configure your monitoring system to send notifications to an external platform whenever a critical alert is triggered.
Bonus functionality 🎁
You're welcome to implement other bonuses as you see fit. But anything you implement must not change the default functional behavior of your project.
You may use additional feature flags, command line arguments or separate builds to switch your bonus functionality on.