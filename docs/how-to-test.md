1. The student has no project-related VMs running
The review will commence from a blank slate. All processes must be executed live, showcasing automated scripts. Any manual intervention will result in project failure.
**How to test:** Run `vagrant status` and ensure no VMs are currently running. Destroy them with `vagrant destroy -f` if any exist.

2. A project's documentation has clear objectives, scope, requirements, and procedures
Student's repository contains all necessary automation and configuration files
Ask the student to describe the files and scripts used for environment automation and configuration.
**How to test:** Review `README.md` and ensure `Vagrantfile`, `setup.yml`, and pipeline files exist and are explained.

3. Student demonstrates proficiency with at least one automation and CI/CD tool
Ask the student to explain their choice of automation and CI/CD tools, comparing them to other available options.
**How to test:** Student should be able to articulate why they used GitHub Actions vs Jenkins.

4. Automation scripts successfully create the required environment
The student must demonstrate their scripts creating at least 5 VMs with proper network and administrative configurations from a blank slate, without manual intervention.
**How to test:** Observe the execution of `super_deploy.sh` or `vagrant up && ansible-playbook setup.yml`. Run `vagrant status` to verify 5 VMs are up.

5. Automation scripts successfully deploy the application
The student must show their scripts deploying the application, which should be accessible via browser, without manual intervention.
**How to test:** Navigate to the Load Balancer IP (e.g., `http://192.168.56.11`) in a browser and verify the app loads properly.

6. The application correctly displays infrastructure metrics
Ask the student to show the infrastructure metrics displayed by the application and explain their significance.
**How to test:** Interact with the application UI to confirm real-time metrics (like CPU, memory, or uptime) are displayed from the backend.

7. Automation scripts exhibit idempotency
Ask the student to explain idempotency and demonstrate it by running their scripts multiple times without issues.
**How to test:** Re-run the `ansible-playbook setup.yml` script. It should run quickly with mostly `ok` tasks and `changed=0`, meaning it didn't needlessly modify an already configured state.

8. CI/CD pipeline effectively tracks and responds to repository changes
Ask the student to demonstrate how the CI/CD pipeline detects and reacts to code changes in the Git repository.
**How to test:** Make a minor text change in a repository file, commit, and push. Show the CI/CD platform automatically triggering a new build.

9. CI/CD pipeline successfully deploys application updates
Ask the student to show error-free CI/CD logs and demonstrate that the newly deployed version is live and has replaced the previous one.
**How to test:** Review the pipeline logs to ensure success, then refresh the browser to see the updated changes live.

**Note**: From number 10 to 26, refer to this link from infra-insight project. It's the same.
https://github.com/emyeugdcd/infrastructure-insight/blob/main/how-to-test.md

10. Automation creates 5 VMs with descriptive names and correct hostname configuration
Ask the student to demonstrate hostname resolution.
hostname on each VM and ping <hostname> from other VMs

11. VMs are assigned static IP addresses
Ask the student to show the IP configuration and verify it persists after a reboot using ip a.

12. Only the Load Balancer VM is accessible externally
Ask the student to explain the network architecture and demonstrate external access limitations.

13. VMs are up-to-date with latest security patches
Ask the student to demonstrate the updated status of each VM
sudo apt update && sudo apt list --upgradable

14. A 'devops' user is created on each VM with appropriate permissions
Ask the student to demonstrate the existence of the user on each VM.
grep devops /etc/passwd

15. SSH key authentication is enforced, and password login is disabled
Ask the student to demonstrate SSH access using keys and attempt password login.

16. The devops user is added to the sudo group
Ask the student to demonstrate sudo access for the devops user
groups devops should output: devops : devops sudo

17. The devops sudo commands are password protected
Ask the student to demonstrate sudo command for the devops user.
sudo visudo must require password

18. Root login is disabled for enhanced security
Ask the student to attempt root login via SSH and explain why it's disabled.
ssh root@<VM_IP>

19. Only user devops can login into all VMs
Student must not be able to login as any other user apart from devops.
ssh linus_torvalds@<VM_IP>

20. Secure umask (022/027/077) is set for all users
Ask the student to show umask configuration and demonstrate it in use

21. Required containerization tools are installed on appropriate servers
Ask the student to show the installed containerization tools.
docker --version or equivalent for other tools

22. Firewall rules are configured to allow appropriate traffic between servers and from external sources
Ask the student to show and explain the firewall rules. No unused ports must be open.
sudo ufw status verbose

23. Backend container is deployed on the application server
Ask the student to show the running backend container.
docker ps or equivalent
docker logs <container_id> to check the logs for any issues.

24. Frontend containers are deployed on both web servers
Ask the student to show the running frontend containers on both web servers.
docker ps or equivalent
docker exec -it <container_id> /bin/sh to access the container shell and verify the environment.

25. Load balancer is configured to distribute traffic between the two web servers
Ask the student to show and explain the load balancer configuration, including the load balancing algorithm. Refresh the application multiple times and confirm that responses come from both web servers.
cat /etc/nginx/nginx.conf or relevant configuration file.
sudo systemctl status nginx or relevant service to check the status.

**Extra**
26. Comprehensive testing is integrated into the CI/CD pipeline
Ask the student to demonstrate and explain automated code quality analysis, performance, and security tests within their pipeline.
**How to test:** Show the `deploy.yml` pipeline file executing linting, static analysis, or testing steps before the build phase.

27. Operational Rollback Mechanism
Ask the student to demonstrate and explain the rollback process, ensuring the application can successfully revert to a previous version.
**How to test:** Modify the code to purposely fail the deployment's health check (`curl`). Show the pipeline logging a failure and automatically reverting the docker container to the `*-old` backup.

28. Pipeline notifications are effectively configured
Ask the student to demonstrate the receipt of notifications for both successful and failed deployments, including explanatory details.
**How to test:** Check Slack, Discord, or Email to verify a success or failure alert was triggered by the pipeline's completion step.

29. The entire deployment process is automated with a single command
Ask the student to demonstrate the fully automated creation of the environment and application deployment using a single command.
**How to test:** Run `./super_deploy.sh` and observe it spinning up Vagrant, running Ansible, building Docker containers, and launching the app without any manual input.

30. Student has implemented additional technologies, security enhancements and/or features beyond the core requirements
**How to test:** Netdata, UFW, WireGuard, etc. are all added for security enhancements and monitoring. 