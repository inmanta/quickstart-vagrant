#!/bin/bash

yum install -y epel-release
cat > /etc/yum.repos.d/inmanta_oss_dev.repo <<EOF
[inmanta-oss-stable]
name=Inmanta OSS stable
baseurl=https://pkg.inmanta.com/inmanta-oss-stable/el7/
gpgcheck=1
gpgkey=https://pkg.inmanta.com/inmanta-oss-stable/inmanta-oss-stable-public-key
repo_gpgcheck=1
enabled=1
enabled_metadata=1
EOF

yum install -y python3-inmanta python3-inmanta-server python3-inmanta-agent mongodb-server

#optimize mongo for small db and fast start
echo "smallfiles = true" >>/etc/mongod.conf

#start mongo
systemctl start mongod
systemctl enable mongod

# configure inmanta
cat >> /etc/inmanta/server.cfg <<EOF
[server]
auto-recompile-wait = 10
agent_autostart = *
EOF

# start inmanta server
systemctl enable inmanta-server
systemctl start inmanta-server

#patch up hosts, for agent autostart
echo "192.168.33.101 vm1" >> /etc/hosts
echo "192.168.33.102 vm2" >> /etc/hosts

#set keys for agent access
mkdir -p /root/.ssh
cp /vagrant/vagrant-master /root/.ssh/id_rsa
mkdir -p /var/lib/inmanta/.ssh
cp /vagrant/vagrant-master /var/lib/inmanta/.ssh/id_rsa
cat > /var/lib/inmanta/.ssh/config <<EOF
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
EOF
chmod 600 /var/lib/inmanta/.ssh/config
chown inmanta -R /var/lib/inmanta/.ssh

