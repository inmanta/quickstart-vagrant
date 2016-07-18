#!/bin/bash

#setup repos
cat > /etc/yum.repos.d/inmanta.repo <<EOF
[inmanta-master]
baseurl=https://packages.inmanta.com/rpms/inmanta/master/fedora/
enabled=1
gpgcheck=0

[inmanta-deps]
baseurl=https://packages.inmanta.com/rpms/deps/fedora/
enabled=1
gpgcheck=0

[inmanta-dash]
baseurl=https://packages.inmanta.com/rpms/inmanta-dashboard/
enabled=1
gpgcheck=0
EOF

#install all packages at once
dnf install -y python3-inmanta-server inmanta-dashboard python3-greenlet python3-pymongo-gridfs mongodb-server python3-blessings

#optimize mongo for small db and fast start
echo "smallfiles = true" >>/etc/mongod.conf

#start mongo 
systemctl start mongod
systemctl enable mongod

#setup the server
cat > /etc/inmanta/server.cfg <<EOF
[config]
# The directory where the server stores its state
state_dir=/var/lib/inmanta

# The directory where the server stores log file. Currently this is only for the output of 
# embedded agents.
log_dir=/var/log/inmanta

heartbeat-interval = 30

[server]

auto-recompile-wait = 10
agent_autostart = *

[dashboard]
# Host the dashboard from within the server. The server does not (yet) override the config.js file
# of the dashboard. This will need to be configured manually. The dashboard will be available
# on the server under /dashboard/
enabled=true
# The path where the dashboard is installed
path=/usr/share/inmanta/dashboard
EOF

systemctl start inmanta-server
systemctl enable inmanta-server

#patch up hosts, for agent autostart
echo "192.168.33.101 vm1" >> /etc/hosts
echo "192.168.33.102 vm2" >> /etc/hosts

#set keys for agent access
cp /vagrant/vagrant-master /root/.ssh/id_rsa
mkdir /var/lib/inmanta/.ssh
cp /vagrant/vagrant-master /var/lib/inmanta/.ssh/id_rsa
chown inmanta -R /var/lib/inmanta/.ssh

#add host to known hosts to prevent warningsz
sudo -u inmanta sh -c "ssh-keyscan -H vm1 >> ~/.ssh/known_hosts"
sudo -u inmanta sh -c "ssh-keyscan -H vm2 >> ~/.ssh/known_hosts"
