SLIM_MODE = ENV['SLIM_MODE'] == 'true'

Vagrant.configure("2") do |config|
  servers = [
    ["loadbalancer", "192.168.56.11", 50022],
    ["webserver1",   "192.168.56.12", 50023],
    ["webserver2",   "192.168.56.13", 50024],
    ["appserver",    "192.168.56.14", 50025],
    ["monitoring",   "192.168.56.17", 50027],
  ]

  unless SLIM_MODE
    servers << ["backup", "192.168.56.15", 50026]
  end

  servers.each do |name, ip, ssh_port|
    config.vm.define name do |node|
      node.vm.box = "bento/ubuntu-22.04"
      node.vm.hostname = name
      node.vm.network "private_network", ip: ip
      # Overriding Vagrant's core default 50022 SSH mapping
      node.vm.network "forwarded_port", guest: 22, host: ssh_port, id: "ssh", auto_correct: true

      # Memory allocation
      mem = if name == "monitoring"
        SLIM_MODE ? "3072" : "3584"
      elsif name == "loadbalancer"
        SLIM_MODE ? "640"  : "1024"
      else
        SLIM_MODE ? "768"  : "1024"
      end

      cpus = (name == "loadbalancer" || name == "monitoring") ? "2" : "1"

      # VMware Fusion (macOS Apple Silicon / Intel)
      node.vm.provider "vmware_fusion" do |v|
        v.vmx["memsize"]  = mem
        v.vmx["numvcpus"] = cpus
      end

      # VMware Desktop / Workstation
      node.vm.provider "vmware_desktop" do |v|
        v.vmx["memsize"]  = mem
        v.vmx["numvcpus"] = cpus
      end

      # VirtualBox (Linux / Windows / macOS fallback)
      node.vm.provider "virtualbox" do |v|
        v.memory = mem.to_i
        v.cpus   = cpus.to_i
        v.gui    = false
        v.name   = "sherlock-logs-#{name}"
      end
    end
  end
end