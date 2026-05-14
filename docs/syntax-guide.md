# DevOps Syntax & Config Guide

When working with DevOps tools, you will encounter many different file formats, and you will see lots of `.yml` or `.yaml` files everywhere. The most important thing to remember is: **YAML is not a programming language!** It is just a way to structure data (like a dictionary in Python or an object in JavaScript) so that tools can read it.

## 1. The Different Languages in this project's stack

* **YAML (`.yml` / `.yaml`)**: Used by Ansible (`setup.yml`), Docker Compose (`docker-compose.yml`), and Prometheus (`prometheus.yml`). It uses indentation (spaces) to define structure. 
* **Logstash DSL (`logstash.conf`)**: Logstash configuration looks a bit like Ruby (because Logstash was written in Ruby!). It uses `{}` brackets and `=>` arrows to define blocks and assign values.
* **PromQL**: This is Prometheus's custom math/query language used *inside* Grafana or Prometheus to calculate metrics (e.g., `rate(http_requests[5m])`).

## 2. Decoding Ansible (`setup.yml`)
Ansible uses YAML to define "Modules" (pre-built python scripts that do the actual work). Here is a breakdown of the module parameters in this project, and if you are still confused, you can refer to the [Ansible documentation](https://docs.ansible.com/ansible/latest/collections/index.html) for more information.

* `state: directory`: Tells the `file` module to ensure a folder exists. If you used `state: absent`, it would delete the folder.
* `cron:`: This module manages Linux cron jobs (scheduled tasks). It creates an entry in `/var/spool/cron/crontabs` so Linux automatically runs your backup script every week.
* `lineinfile:`: A surgical tool. Instead of replacing a whole file, it looks for a specific line (using a Regex pattern) and replaces just that one line. We use it to edit `/etc/ssh/sshd_config` safely.
* `shell:`: Runs a raw bash command on the target server, exactly as if you typed it in the terminal.
* `args:`: Used to pass extra rules to the `shell` command. We use `creates: /some/file` which tells Ansible: "If this file already exists, don't run the shell command again" (this makes the shell command Idempotent!).
* `debug:`: The `console.log()` or `print()` of Ansible. It prints variables to the screen so we can see what is happening during the deployment.
* `apt:`: The Ubuntu package manager module. Equivalent to typing `apt-get install nginx`.
* `apt_repository:` and `repo:`: Adds a third-party software library to Ubuntu. We needed this to download Filebeat directly from Elastic's official servers.
* `update_cache: yes`: The equivalent of running `apt-get update` before installing.
* `mode: '0755'`: Linux file permissions. `0755` means the Owner can Read/Write/Execute, and everyone else can Read/Execute.
* `value: '262144'`: Used in the `sysctl` module. Elasticsearch is a massive Java application that requires the Linux kernel to allow it to map a huge amount of memory. We change the kernel variable `vm.max_map_count` to the value `262144` so Elasticsearch doesn't crash on boot.

## 3. The WireGuard Dynamic Loop Explained

In `setup.yml`, we had this block of code:
```yaml
    - name: Add WireGuard Peers dynamically
      blockinfile:
        path: /etc/wireguard/wg0.conf
        block: |
          [Peer]
          PublicKey = {{ hostvars[item]['wg_public_key'] }}
          Endpoint = {{ hostvars[item]['ansible_host'] }}:51820
      when: item != inventory_hostname
      with_items: "{{ ansible_play_hosts }}"
```

### What happened here?
For a VPN like WireGuard to work, every server needs to know the "Public Key" and "IP Address" of every *other* server. Writing this manually for 6 servers would require 30 separate configuration blocks! 

Instead, we used Ansible "Magic":
1. `with_items: "{{ ansible_play_hosts }}"`: This tells Ansible to **Loop** over every server in our inventory.
2. `when: item != inventory_hostname`: This is an `IF` statement. It says "Only do this if the server in the loop is NOT myself" (a server doesn't need to connect to itself).
3. `hostvars[item]['wg_public_key']`: As Ansible loops through the servers, it grabs the public key that was generated on *that specific server* and injects it into the config block.

**The Purpose:** It automatically builds a complete, interconnected "Mesh" VPN configuration perfectly, no matter if you have 6 servers or 600 servers!
