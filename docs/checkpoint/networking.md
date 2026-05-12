1. What is a private network in the context of your Vagrant setup? Can external traffic reach your VMs?

In my Vagrantfile, private_network assigns each VM an IP in the 192.168.56.0/24 range. This is a host-only network: my Mac can reach the VMs and the VMs can reach each other, but nothing outside my Mac can reach them. There's no route from the internet to 192.168.56.x. This is why my GitHub Actions pipeline can't SSH into my VMs: the GitHub runner is a cloud machine with no path to a private host-only network. To expose VMs to external traffic I'd either use Vagrant's forwarded_port (which maps a host port to a guest port) or deploy to cloud VMs with public IPs.


2. What is a load balancer and what does least_conn mean?
A load balancer sits in front of multiple servers and distributes incoming requests across them. This serves two purposes: it prevents any single server from being overwhelmed, and it provides redundancy: if one server dies, traffic goes to the others. In my project, Nginx on the loadbalancer VM distributes HTTP requests between webserver1 and webserver2. least_conn is the balancing algorithm: it sends each new request to whichever server currently has the fewest active connections. This is smarter than round-robin (which just alternates) because it accounts for requests that take different amounts of time to process.


3. What is UFW and how did you configure it in this project?
UFW (Uncomplicated Firewall) is a frontend for iptables: Linux's packet filtering system. It controls which network traffic is allowed in and out of a VM. In my Ansible playbook, the default policy is deny incoming, then specific ports are opened per VM role: port 22 (SSH) on all VMs, port 80 (HTTP) only on the loadbalancer, port 8080 (backend API) only on the appserver, port 3000 (frontend) only on the webservers. This principle of least privilege means each VM only accepts traffic it legitimately needs. A compromised webserver can't directly attack the appserver on port 8080 because UFW would block the connection.


4. What is WireGuard and what is it supposed to do in your infrastructure?
WireGuard is a modern VPN protocol. In my infrastructure the intent is to create an encrypted tunnel between all VMs so that inter-VM communication goes through the VPN rather than the unencrypted private network. Each VM would get a WireGuard IP in the 10.8.0.0/24 range. In practice my current setup installs WireGuard and generates keys on each VM, but doesn't configure peers: so the VPN interface starts but no encrypted traffic actually flows between VMs because no VM knows the other VMs' public keys. A complete implementation requires a two-pass approach: collect all public keys first, then distribute them to each VM's wg0.conf as peer entries.


5. What is the /etc/hosts file and why did you configure it with Ansible?
/etc/hosts is a local DNS lookup table: before a machine queries a DNS server, it checks this file. If it finds a match, it uses that IP without going further. My Ansible playbook writes all 6 VM hostnames and IPs into /etc/hosts on every VM so they can refer to each other by name (loadbalancer, appserver, webserver1 etc.) instead of IP addresses. This makes configs more readable and means if an IP changes you update /etc/hosts in one Ansible task rather than hunting through every config file. In production this would be replaced by proper internal DNS, but for a local lab environment static /etc/hosts is practical.