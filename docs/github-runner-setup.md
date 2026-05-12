# Self-Hosted GitHub Actions Runner Setup Guide

This document serves as a future reference for setting up a self-hosted GitHub Actions runner inside a private network (like our Vagrant VMs). This solves the issue of GitHub's cloud runners not being able to reach private IP addresses.

## Why use a self-hosted runner?
When your infrastructure sits on a private network (e.g., `192.168.56.x` or an AWS VPC without public IPs), GitHub's cloud servers cannot SSH into them. By installing a runner *inside* that private network, the runner polls GitHub for jobs and executes them locally, with full access to the internal network.

## Setup Instructions

### 1. Generate the Runner Token
1. Go to your repository on GitHub.com
2. Navigate to **Settings** > **Actions** > **Runners**
3. Click the green **New self-hosted runner** button.
4. Select the **Linux** OS and **x64** Architecture. 
5. GitHub will generate a block of commands containing a unique download URL and a secret token. Keep this page open.

### 2. Connect to the Target Server
SSH into the server where you want the runner to live. In the Sherlock Logs project, the `backup` server is a great lightweight host:
```bash
vagrant ssh backup
```

### 3. Download and Configure the Runner
*Note: Replace the URL and Token below with the exact ones provided by GitHub in Step 1.*

```bash
# Create a folder for the runner
mkdir actions-runner && cd actions-runner

# Download the latest runner package
curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/download/v2.314.1/actions-runner-linux-x64-2.314.1.tar.gz

# Extract the installer
tar xzf ./actions-runner-linux-x64.tar.gz

# Configure the runner (PASTE YOUR UNIQUE COMMAND FROM GITHUB HERE)
./config.sh --url https://github.com/YourUsername/YourRepo --token YOUR_SECRET_TOKEN
```

During configuration, it will ask you for a few details (like the runner name and work folder). You can just press `Enter` to accept the default values.

### 4. Install as a Background Service
By default, the runner stops if you close your terminal. To install it as a permanent background service so it always runs when the VM boots up:
```bash
sudo ./svc.sh install
sudo ./svc.sh start
```

### 5. Update your Pipeline File
Once the runner is connected, go back to your `.github/workflows/deploy.yml` file and update the `runs-on` property for your jobs:

```yaml
jobs:
  deploy_backend:
    name: Deploy Backend
    # Change from 'ubuntu-latest' to 'self-hosted'
    runs-on: self-hosted
    steps:
      # ... your steps here
```

Now, whenever you push code, GitHub will send the job directly to your `backup` VM, which will flawlessly SSH into `192.168.56.14` because it's on the same private network!
