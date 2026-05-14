Mandatory

1. Student can explain the difference between push-based and pull-based monitoring systems and justify why Prometheus uses a pull-based model.

2. Student can describe the architecture of the ELK stack and explain the role of each component (Elasticsearch, Logstash, Kibana).

3. Student can explain the advantages and disadvantages of using Prometheus over other monitoring tools like Nagios or Zabbix.

4. Prometheus scrapes metrics at appropriate intervals. Student can explain how to adjust the scrape interval.

5. Node Exporter and cAdvisor (or other similar tools) are configured correctly. Student can describe common issues that might arise during their setup, such as firewall rules or incorrect endpoint configurations.

6. Student can explain the benefits of using Grafana for visualization compared to other tools like Kibana or Datadog.

7. Application metrics are exposed in a Prometheus-compatible format. Student can explain how to use Prometheus client libraries to achieve this.

8. Application sends at least one custom metric to Prometheus.
Application sends logs to Logstash. Student can describe how to handle log format inconsistencies and parsing errors.

10. Grafana dashboards are created with appropriate data sources. Student can explain how to use Grafana's query editor to filter and aggregate data.
VM Performance Dashboard
Docker Container Dashboard
Application Performance Dashboard

11. Kibana dashboards are created with effective visualizations. Student can describe how to use Kibana's search and filtering capabilities to analyze logs.
System Logs Dashboard
Application Logs Dashboard
Docker Logs Dashboard

12. System provides real-time performance metrics across the infrastructure. Student can explain how to troubleshoot common issues with metric collection.

13. Historical performance data is available through the implemented tools. Student can explain how to create long-term retention policies for metrics and logs.

14. Setup of the new monitoring and logging VM is incorporated into the existing automation flow.

15. CI/CD pipeline deploys monitoring and logging agents. Student can describe how to handle agent configuration dynamically based on the environment.

16. Grafana alerts are configured with appropriate thresholds. Student can explain how to avoid alert fatigue by setting sensible alert conditions.

17. Logstash sends alert notifications based on log patterns. Student can explain how to use Logstash filters to parse and match log entries.

18. Student can explain how to fine-tune alert thresholds and conditions to reduce false positives.

19. Alerts trigger when CPU usage exceeds 80% for more than 5 minutes.
Run stress-ng --cpu 8 --timeout 360s or similar to simulate high CPU usage. Adjust time as necessary.

20. Alerts trigger when available disk space falls below 20%.
Run fallocate -l 10G large_file.img or similar to simulate low disk space.

21. Alerts trigger when memory usage exceeds 90% for more than 5 minutes.
Run stress-ng --vm 2 --vm-bytes 80% --timeout 360s or similar to simulate high memory usage. Adjust time as necessary.

22. Alerts trigger when a container restarts more than 3 times in 15 minutes.
Run docker run --restart=always --name test_container ubuntu /bin/bash -c "sleep 10; exit 1" or similar to simulate container restarts.

23. Alerts trigger when container memory usage exceeds 80% of its limit.
Run docker run -m 512m --name memory_test ubuntu /bin/bash -c "stress-ng --vm 1 --vm-bytes 450M --timeout 360s" or similar to simulate high container memory usage.

24. Alerts trigger when any VM becomes unreachable.
Run sudo ifconfig eth0 down or similar to simulate a VM becoming unreachable.

25. Alerts trigger when Elasticsearch cluster status changes to yellow or red.
Stop one of the Elasticsearch nodes in a multi-node cluster to simulate a yellow state.

26. The README file contains a clear project overview, setup instructions, and usage guide.

27. The code is well-organized, properly commented, and follows best practices for the chosen programming language(s).

Extra
28. Advanced alerting rules trigger based on trends or combinations of metrics. Student can describe how to use Prometheus' PromQL to create complex alert conditions.

29. Monitoring system sends notifications to an external platform. Student can explain how to handle notification throttling and escalation policies.

30. Student has implemented additional technologies, security enhancements and/or features beyond the core requirements.