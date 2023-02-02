# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Basic Setup
  (1..3).each do |i|
    config.vm.define "node#{i}" do |node|
      node.vm.box = "ubuntu/focal64"
      node.vm.hostname = "node#{i}"
      node.vm.network "private_network", ip: "10.0.0.#{i*10}"  
      node.vm.provider "virtualbox" do |vb|
        vb.memory = "3072"
        vb.cpus = "2"
      end

      # Add hostnames to /etc/hosts  
      (1..3).each do |j|
        node.vm.provision "shell", inline: <<-SHELL
          echo "10.0.0.#{j*10} node#{j}" >> /etc/hosts
        SHELL
      end

      # Configure SSH Keys across nodes
      config.vm.provision "file", source: "id_rsa", destination: "/home/vagrant/.ssh/id_rsa"
      public_key = File.read("id_rsa.pub")
      config.vm.provision "shell" do |s|
        s.inline = <<-SHELL
          mkdir -p /home/vagrant/.ssh
          chmod 700 /home/vagrant/.ssh
          echo '#{public_key}' >> /home/vagrant/.ssh/authorized_keys
          chmod 600 /home/vagrant/.ssh/id_rsa
          chmod 600 /home/vagrant/.ssh/authorized_keys
          echo 'Host 10.0.0.*' >> /home/vagrant/.ssh/config
          echo 'StrictHostKeyChecking no' >> /home/vagrant/.ssh/config
          echo 'UserKnownHostsFile /dev/null' >> /home/vagrant/.ssh/config
          chmod 600 /home/vagrant/.ssh/config
        SHELL
      end 

      # Provision Scripts
      node.vm.provision "shell", path:"bootstrap.sh"  
      
    end
  end
end

