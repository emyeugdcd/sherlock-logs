# Learning Notes: The Shift to Automation Alchemy

So I now have some experience with **Infrastructure as Code (IaC)** thanks to the previous two projects, **Server Sorcery 101** and **Infrastructure Insight**, which you can find on my github profile(@emyeugdcd). In the previous projects, I wrote code (Ansible, Vagrant) that built the virtual machine environments. However, I still had to *manually* trigger the processes. For example, I had to type `ansible-playbook setup.yml`, and if I wanted to update the website's CSS, I had to manually run `docker build` again.

**Automation Alchemy** introduces the next evolution of DevOps: **Continuous Integration & Continuous Deployment (CI/CD)**. 

## Concepts covered
Here are the new concepts needed for this chapter:
### 1. The CI/CD Pipeline (The Assembly Line)
Instead of running commands manually, we introduce a "Robot Manager" (like Jenkins, GitLab CI, or GitHub Actions). This robot constantly watches your Git repository. The second you run `git push`, the robot wakes up and executes a pipeline of tasks automatically. 

### 2. Testing Integration (Quality Gates)
Before the robot deploys the code, it tests it. 
*   **Static Analysis:** It scans Node.js and Go code for syntax errors.
*   **Security Scans:** It checks if we accidentally pushed a password or SSH key.
*   If *any* test fails, the robot rejects the deployment and sends an alert. It prevents the delivery of broken code!

### 3. Artifacts and Registries
In the previous project, I built Docker images natively *on* the target servers using `/vagrant` folders. In a true enterprise, servers do not build their own code! 
The CI/CD robot checks out our code, builds the Docker Image itself, and pushes that image to a **Docker Registry** (like DockerHub). Then, it simply tells the web servers to "pull and run" the finished artifact. 

### 4. Rollback Strategies
What happens if the robot deploys the code, but the website crashes? A rollback strategy means the robot keeps the *old* Docker container paused in the background. If the new one fails a health check, the robot instantly deletes the new one and unpauses the old one in milliseconds.

### 5. One-Click Automation (The Holy Grail)
This is the ultimate goal of the project. A single script (`./super_deploy.sh`) that you can run on a completely empty Mac. It will boot all the VMs, install the firewalls, install the CI/CD robot, build the code, and launch the website without you touching the keyboard a second time.

## Improvements made compared to previous projects (server-sorcery & infrastructure-insight)

### 1. The Netdata Port (Principle of Least Privilege)
What changed: I added `when: inventory_hostname in ['webserver1', 'webserver2', 'appserver']` to the UFW rule for port 19999. 

Explanation: By default, our Ansible script was indiscriminately opening port 19999 on every machine (even the load balancer and backup server). So I have learnt that in DevOps and security, we follow the **Principle of Least Privilege**. That is, if a machine isn't running a specific service, its firewall should absolutely not have that port open. It’s an unnecessary attack vector.

### 2. Hardcoded Passwords (Secret Management)
What changed: In `setup.yml`, I changed the hardcoded password string to `{{ devops_password | password_hash('sha512', 'mysecretsalt') }}`. In `super_deploy.sh`, I added `--extra-vars "devops_password=SuperSecurePassword123!"` to my Ansible execution. 

Explanation: Never commit passwords, API keys, or secrets to a Git repository. Ever. If your repo goes public, bots will scrape those secrets in seconds. By using variables (`{{ devops_password }}`), the password is no longer in the code. Instead, we should inject it at runtime using `--extra-vars`. In a real production environment, we wouldn't even put it in the bash script; we would use a secure vault like Ansible Vault, HashiCorp Vault, or AWS Secrets Manager to inject it securely during the pipeline run.

### 3. WireGuard's Two-Pass Peer Distribution
What changed: I completely rewrote the WireGuard Ansible block to use a "Two-Pass" approach.

Pass 1: Ansible generates the Private/Public keys on every VM, and then uses the `slurp` module to read all those Public Keys back into Ansible's memory (`set_fact`).
Pass 2: Ansible goes back to every VM and dynamically builds the `wg0.conf` file by looping through all the other VMs (`ansible_play_hosts`) and injecting their specific Public Keys and IP addresses into the `[Peer]` blocks.

Explanation: WireGuard is a peer-to-peer cryptokey routing VPN. It doesn't have a traditional "server/client" model. For VM A to talk to VM B securely, A needs B's public key, and B needs A's public key. If we just install WireGuard (which is what I did previously in the previous two projects), the interface turns on, but it has no idea who it's allowed to talk to.

**Practicality in Production:** This is extremely common and practical! Companies use this exact automated pattern to dynamically link multi-cloud environments (e.g., creating a secure mesh between AWS servers and Google Cloud servers). Every time a new server is spun up, Ansible or Terraform distributes its public key to the rest of the fleet so they can all communicate securely.

### 4. Reclaiming Jenkins' Wasted Resources
What changed: I completely removed `cicd-server` from my `Vagrantfile`, `inventory.ini`, `/etc/hosts`, and stripped the Jenkins installation out of `setup.yml`. 

Explanation: We have migrated to GitHub Actions, meaning GitHub's cloud servers are now doing the heavy lifting of building our Docker images. Running a heavy Java application like Jenkins on a dedicated VM locally when it's doing absolutely nothing is just burning RAM and CPU. We killed the VM which was built initally for Jenkins. The reason why I chose Github Actions over Jenkins is because it integrates seamlessly with GitHub and is easy to use. Also, GitHub Actions is a cloud-based CI/CD tool that allows you to automate your software development workflows right from your GitHub repository. More information on this, check `jenkins-vs-github-actions.md` file in `docs` folder.
