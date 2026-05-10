# Jenkins vs. GitHub Actions: A Comparison Guide

This document compares Jenkins and GitHub Actions based on the pipeline I built for **Automation Alchemy**, to help you (and myself also for future reference) understand their syntax, purposes, and practicality in real-life production environment. To be honest, I have only had experience working with Github Actions, so I studied by myself about Jenkins, then I asked AI to summarize for me the differences. Below is the output that I received, that I have read, learnt and edited for clarity and relatability to my project.

## 1. Syntax Comparison

Both tools define CI/CD pipelines, but their approach and language are completely different.

| Feature | Jenkins (`Jenkinsfile`) | GitHub Actions (`deploy.yml`) |
| :--- | :--- | :--- |
| **Language** | Groovy-based Domain Specific Language (DSL) | YAML |
| **Structure** | `pipeline` -> `stages` -> `stage` -> `steps` | `jobs` -> `steps` |
| **Variables** | `environment { VAR = 'value' }` | `env:` block |
| **Triggers** | Often configured in the UI or via Webhooks | `on: [push, pull_request, workflow_dispatch]` |
| **Dependencies**| Sequential by default (stages run in order) | `needs: job_name` (runs parallel by default unless specified) |
| **Post-actions**| `post { success {} failure {} }` | Next job with `if: always()` and checking `needs.job_name.result` |

### Code Example: Environment Variables
**Jenkins:**
```groovy
environment {
    BACKEND_IP = '192.168.56.14'
}
```

**GitHub Actions:**
```yaml
env:
  BACKEND_IP: '192.168.56.14'
```
*In GitHub Actions, you use `${{ env.BACKEND_IP }}` to access it.*

## 2. Core Differences in Philosophy

### Jenkins
- **Self-Hosted First:** You own the master server. You install it, patch it, and maintain plugins.
- **Plugins Rule Everything:** Jenkins functionality heavily relies on thousands of community plugins. If a plugin breaks or becomes outdated, your pipeline might break.
- **Groovy Power:** Because it's based on Groovy, a full programming language, you can write incredibly complex logic right inside your Jenkinsfile (e.g., `for` loops, complex conditionals).
- **Agents/Nodes:** You attach external servers (agents) to Jenkins so it can run jobs on them.

### GitHub Actions
- **Cloud-Native / Managed First:** GitHub hosts the runners (though you can use self-hosted ones). You don't manage a master server.
- **Action Marketplace:** Instead of plugins, you use "Actions" (small, reusable pieces of code defined in repositories). E.g., `uses: actions/checkout@v3`.
- **YAML Simplicity:** It's strict YAML. It's much easier to read for beginners, but writing complex scripting logic directly in YAML is harder than in Groovy. (Best practice is to write a bash/python script and just call it from YAML).
- **Native Integration:** It's built right into your code repository. The UI for logs and PR checks is seamless.

## 3. Practicality for Our Project (Automation Alchemy)

Our project uses **local Vagrant VMs (192.168.56.x)**.

### Using Jenkins (Our Initial Setup)
- **Practicality:** HIGH (for our specific local lab).
- **Why?** We spun up a 6th VM to be the Jenkins server. Since it lives on the exact same private network (`192.168.56.0/24`) as the web and backend servers, it could easily SSH into them and run deployment commands directly.

### Using GitHub Actions (Our New Setup)
- **Practicality in Cloud:** HIGH.
- **Practicality in Local Lab:** CHALLENGING without extra setup.
- **Why?** By default, GitHub Actions runs on GitHub's cloud servers. These cloud servers **cannot** reach our local laptop's `192.168.56.x` private Vagrant network.
- **How to make it work locally?**
  1. **Self-Hosted Runner:** You would need to install the GitHub Actions Runner agent inside one of your Vagrant VMs (or your host machine). This tells GitHub Actions to send the job to your local machine instead of running it in the cloud.
  2. **Mocking/Studying:** We can write the pipeline (as we did in `.github/workflows/deploy.yml`) to understand the syntax, but it will fail on the SSH steps on GitHub's cloud unless we expose those VMs to the internet (e.g., using Ngrok) or use a self-hosted runner.

## 4. Summary: Which one should you use?

- **Use GitHub Actions if:** You are starting a modern cloud project, your code is on GitHub, and you want minimal infrastructure maintenance overhead. It's the industry standard for new open-source and cloud-native projects.
- **Use Jenkins if:** You are working in a large enterprise with on-premise servers, complex legacy pipelines, or need complete control over your CI/CD infrastructure and security.

### Bonus: Which one should I use for the next project (ELK & Prometheus)

Ditching Jenkins was the best thing I could have done for the next project. Here is why: 

The next project is about monitoring and logging using ELK and Prometheus. So we need to have a platform to monitor and log the applications and infrastructure. 

Separation of Concerns: CI/CD (GitHub Actions) is for Deploying code. Monitoring/Logging (Prometheus, Grafana, ELK) is for Observing the infrastructure. They don't conflict. GitHub Actions will still deploy your updated metrics app, and your VMs will run the monitoring tools.
For my home lab with limited resources, this is a huge win. 

I desperately need the RAM! Why? Elasticsearch, Logstash, and Prometheus are notorious memory hogs. They are incredibly heavy JVM/Go applications. By choosing Github Actions and removing Jenkins (that supposedly comes with a new VM), I freed up 1GB of RAM and CPU cycles on my host machine. I can now use that exact RAM to spin up a new VM dedicated entirely to the ELK stack and Prometheus!

So basically, I will use GitHub Actions to deploy the code updates (adding Prometheus client libraries to my apps), and Ansible to provision the infrastructure (installing Node Exporter, Filebeat, Logstash, etc., on the VMs).