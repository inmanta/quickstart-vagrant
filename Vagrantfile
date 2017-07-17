# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|

  config.ssh.forward_agent = true

  config.vm.define "vm1" do |vm1|
    vm1.vm.box = "centos/7"
    #fixed IP
    vm1.vm.network "private_network", ip: "192.168.33.101"
    # expose drupal
    vm1.vm.network :forwarded_port, guest: 80, host: 8080
    # make machine accessible to our remote agent
    vm1.vm.provision "shell", inline: "mkdir /root/.ssh"
    vm1.vm.provision "shell", inline: "cat /vagrant/vagrant-master.pub >>/root/.ssh/authorized_keys"
    # centos no longer brings up eth1
    vm1.vm.provision "shell", inline: "ifup eth1"
  end


  config.vm.define "vm2" do |vm2|
    vm2.vm.box =  "centos/7"
    # fixed IP
    vm2.vm.network "private_network", ip: "192.168.33.102"
    # make machine accessible to our remote agent
    vm2.vm.provision "shell", inline: "mkdir /root/.ssh"
    vm2.vm.provision "shell", inline: "cat /vagrant/vagrant-master.pub >>/root/.ssh/authorized_keys"
    # centos no longer brings up eth1
    vm2.vm.provision "shell", inline: "ifup eth1"
  end

  config.vm.define "server" do |server|
    server.vm.box = "centos/7"
    # fixed IP
    server.vm.network "private_network", ip: "192.168.33.10"
    # expose the dashboard
    server.vm.network :forwarded_port, guest: 8888, host: 8888
    # install the server
    server.vm.provision "shell", path: "server.sh"
    # centos no longer brings up eth1
    server.vm.provision "shell", inline: "ifup eth1"
  end
end
