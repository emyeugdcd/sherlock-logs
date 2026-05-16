# Incident Postmortems & Bug Log

*I have just learnt a new concept through this project. In DevOps, when things break, we write a "Postmortem" document. It records the symptom, the root cause, and the fix so the team never makes the same mistake twice. Here is the documentation of the postmortem I encountered during this project!*

---

## Incident 1: The YAML Indentation Chain Reaction
**Symptom:** 
Running `./super_deploy.sh` failed. Ansible threw an error `conflicting action statements: lineinfile, validate` and crashed. Immediately after, the deployment script failed with `Permission denied (publickey,password)` when trying to SSH into the VMs.

**Root Cause:**
In `setup.yml`, the `validate` argument was indented at the exact same level as the module name `lineinfile:`. Because of this 2-space YAML formatting error, Ansible interpreted `validate` as a completely separate command (which doesn't exist). 
Because Ansible crashed early, the task to create the `devops` user never ran. Thus, when the bash script tried to SSH in as `devops`, it failed with "Permission denied".

**The Fix:**
Indented `validate` by two spaces so it became a child argument of the `lineinfile` module.
YAML is really sensitive to indentation, so we really have to be careful when writing YAML files.
---

## Incident 2: The "Ghost Directory" Docker Crash
**Symptom:**
The new `alertmanager` container failed to start correctly.

**Root Cause:**
In `docker-compose.yml`, I added a volume mapping: `- ./alertmanager.yml:/etc/alertmanager/alertmanager.yml`. However, I forgot to actually create the `alertmanager.yml` file on my local machine! (Thank you random tutorial... I have learnt my lesson...)
When Docker sees a volume mapping for a file that doesn't exist, it panics and automatically creates a **folder** with that name instead. Alertmanager crashed because it was trying to read a configuration file, but found a folder instead!

**The Fix:**
Created a basic `alertmanager.yml` file on the host machine before running `docker-compose up`.

---

## Incident 3: The Blind Prometheus
**Symptom:**
Prometheus was not loading advanced PromQL alert rules.

**Root Cause:**
Two small configuration mismatches:
1. In `prometheus.yml`, I told it to look for a file called `rules.yml`, but I actually named the file `alert_rules.yml`.
2. Even if the name matched, Prometheus couldn't see the file because I didn't mount `alert_rules.yml` into the Prometheus container in `docker-compose.yml`!

**The Fix:**
Updated the config to point to `alert_rules.yml` and added `- ./alert_rules.yml:/etc/prometheus/alert_rules.yml` to the container's volume list.

---

## Incident 4: The 16GB Logstash Explosion
**Symptom:**
During an Ansible deployment, the `monitoring` VM suddenly became `UNREACHABLE` with the error: `mkdir: cannot create directory ‘/home/devops/.ansible’: No space left on device`. The 30GB hard drive was at 100% capacity.

**Root Cause:**
Inside `logstash.conf`, I left a debugging line in the output section: `stdout { codec => rubydebug }`. 
This told Logstash to print a pretty-formatted copy of *every single log* it received directly to the terminal. Docker captures all terminal output and saves it to a `json.log` file on the host machine. Because we had 6 VMs constantly streaming logs, this file rapidly grew to 16 Gigabytes, completely filling the hard drive.

**The Fix:**
1. Used the Linux `truncate` command (`sudo truncate -s 0 /var/lib/docker/containers/...-json.log`) to instantly empty the massive file down to 0 bytes without disrupting the running Docker daemon. This instantly freed 14GB of space.
2. Removed the `stdout { codec => rubydebug }` line from `logstash.conf` so Logstash only sends logs silently to Elasticsearch.

## Incident 5: The Zombie Container
**Symptom:**
I fixed everything from incident 4, but when I ran the script ./super_deploy.sh, it still failed with the same error message. Why?

**Root Cause:**
I discovered the classic DevOps "Catch-22"! 
What is Catch-22? It refers to a paradoxical situation from Joseph Heller's 1961 novel of the same name where a character wants to be grounded from flying military combat missions due to insanity, but the very act of requesting to be grounded would prove his sanity, as only an insane person would want to fly these dangerous missions. This creates a situation where there is no logical way out.
Here is exactly what happened: 
Following incident 4, I had:
- deleted the stdout line from my local logstash.conf on my Mac.
- used truncate on the VM to get my 14GB of space back.
- ran ./super_deploy.sh. This script tries to run Ansible first, and then it updates Docker second.
BUT... between the time I truncated the file and the time Ansible tried to connect, the Logstash container on the VM was still running with the old configuration in its memory! It never stopped!
Logstash immediately spat out another 14GB of logs in 5 minutes, instantly filling my hard drive back to 100%.
Ansible tried to connect, saw the disk was 100% full, and crashed. Because Ansible crashed, my new fixed logstash.conf file never got copied to the VM!
Thus, I was stuck in a loop: I can't deploy the fix because the disk is full, and the disk is full because I can't deploy the fix!

**The Fix:**
Here is how I break the loop:

- SSH into the VM: vagrant ssh monitoring
- Immediately empty the massive log file again: sudo truncate -s 0 /var/lib/docker/containers/7733172d32532d0da14c4c7d9ff1409e4c36b008c88aca7880d81749f90ee2d1/7733172d32532d0da14c4c7d9ff1409e4c36b008c88aca7880d81749f90ee2d1-json.log
- IMMEDIATELY kill the Logstash container before it can write any more logs: sudo docker stop logstash
- Exit and run ./super_deploy.sh again

## Incident 6: The "ContainerConfig" Upgrade Trap
**Symptom:**
After resolving Incident 5, I ran `./super_deploy.sh` again, but it failed at the very end when trying to start Docker Compose. The error was `KeyError: 'ContainerConfig'` during the recreation of the `prometheus` container.

**Root Cause:**
Because I added new volume mappings to `prometheus.yml`, `docker-compose` tried to "recreate" the container. To do this, it reads the metadata of the old container (which was built from `prom/prometheus:latest`). However, the version of Docker Compose installed via Ubuntu `apt` (`v1.29.2`) is quite old. It crashed because modern Docker images no longer include the `ContainerConfig` field in their metadata!
I was stuck in a state where docker-compose could not update the container because it couldn't read the old container's metadata.

**The Fix:**
There were two ways to fix this:
1. *The Manual Fix*: Manually delete the old container (`sudo docker rm -f prometheus`) so docker-compose doesn't try to migrate it and instead builds a fresh one.
2. *The Code Fix*: I downgraded the image tag in `docker-compose.yml` from `prom/prometheus:latest` to `prom/prometheus:v2.43.0` (a slightly older version that still contains `ContainerConfig`) so that `docker-compose v1.29.2` would not crash.
Ultimately, I just destroyed and rebuilt all the VMs (`vagrant destroy` then `./super_deploy.sh`), which gave me a completely fresh environment where the bug no longer existed!