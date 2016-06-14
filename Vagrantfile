# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  
  config.ssh.forward_agent = true
  
  config.vm.define "vm1" do |vm1|
    vm1.vm.box = "fedora/23-cloud-base"
    vm1.vm.network "private_network", ip: "192.168.33.101"
    vm1.vm.network :forwarded_port, guest: 80, host: 8080
    vm1.vm.provision "shell", inline: "cat /vagrant/vagrant-master.pub >>/root/.ssh/authorized_keys"
    vm1.vm.provision "shell", inline: "dnf install -y python"
  end
  

  config.vm.define "vm2" do |vm2|
    vm2.vm.box =  "fedora/23-cloud-base"
    vm2.vm.network "private_network", ip: "192.168.33.102"
    vm2.vm.provision "shell", inline: "cat /vagrant/vagrant-master.pub >>/root/.ssh/authorized_keys"
     vm2.vm.provision "shell", inline: "dnf install -y python"
  end

  config.vm.define "server" do |server|
    server.vm.box = "fedora/23-cloud-base"
    server.vm.network "private_network", ip: "192.168.33.10"
    server.vm.network :forwarded_port, guest: 8888, host: 8888
    server.vm.provision "shell", path: "server.sh"
  end


  
end
