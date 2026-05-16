# Mac RAM Upgrades & VM Optimization Guide

In the previous projects, we have been allocating 2GB of RAM to each VM, totaling 12GB for the entire cluster. However, this is not optimal as some VMs require less RAM than others and now, in this fourth project, I needed to add a new VM which is used for monitoring and logging, so it required more RAM (because ELK is a beast who feeds vigorously on RAM) By simply adding a new VM, we would be using 14GB of RAM in total, which would fry my computer and probably will crash due to the lack of RAM. So I decided to experiment with the RAM allocations for each VM to reduce the total RAM usage while maintaining the same functionality.

## 2. Min-Maxing VM RAM Allocations
**Can we min-max all the VMs so the outcome of the project is the same but uses less memory?**
Absolutely! Giving a VM more RAM than it actually uses is just wasted money in the real world production also. 

By default, I have been allocating 2GB of RAM to each VM, which brought my total to ~12GB. I have optimized my `Vagrantfile` to dramatically reduce this footprint to **8.5 GB total** without sacrificing any functionality.

Here is the new breakdown:

| VM Name | Old RAM | New RAM | Why? |
| :--- | :--- | :--- | :--- |
| **loadbalancer** | 1024 MB | 1024 MB | While Nginx is incredibly lightweight, Ubuntu Server 22.04 requires at least 1GB to boot reliably without OOM panics. |
| **backup** | 1024 MB | 1024 MB | Same as above. The OS needs 1GB to boot, even if the cron job does almost nothing. |
| **webserver1** | 1024 MB | 1024 MB | Runs a small Node.js container and cAdvisor. |
| **webserver2** | 1024 MB | 1024 MB | Same as `webserver1`. |
| **appserver** | 2048 MB | 1024 MB | Runs the Go backend and cAdvisor. Go is extremely memory efficient compared to Java or Node. so we can afford to give it 1GB of RAM less. |
| **monitoring** | 4096 MB | 3584 MB (3.5 GB) | Runs the ELK stack, Prometheus, and Grafana. Elasticsearch and Logstash are Java applications that require large heap sizes. We constrained them to 1GB and 512MB respectively in the `docker-compose.yml`, so 3.5GB for the whole VM gives them enough breathing room. |

**Total Impact:** I cut the RAM usage significantly (from 10GB down to 8.5GB). My Mac will now handle this cluster smoothly, and during this process of trials and errors, I have also established the fact that 1GB is the hard minimum for Ubuntu 22.04 VMs! (I tried 0.5GB at first, and the VM failed to boot...)
