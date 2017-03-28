#!/bin/bash

#install all packages at once
dnf install -y python3 python3-pip python3-virtualenv git mongodb-server

#optimize mongo for small db and fast start
echo "smallfiles = true" >>/etc/mongod.conf

#start mongo
systemctl start mongod
systemctl enable mongod

# install inmanta with pip
python3 -m virtualenv -p python3 /opt/inmanta
P=/opt/inmanta/bin/python3
$P -m pip install -U pip setuptools
$P -m pip install git+https://github.com/inmanta/inmanta#egg=inmanta

#setup the server
mkdir /etc/inmanta
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

cat > /etc/systemd/system/inmanta-server.service << EOF
[Unit]
Description=The server of the Inmanta platform
After=network.target

[Service]
Type=simple
User=inmanta
Group=inmanta
ExecStart=/opt/inmanta/bin/python3 -m inmanta.app -c /etc/inmanta/server.cfg -vv server
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

mkdir /var/lib/inmanta
useradd -r -d /var/lib/inmanta inmanta
mkdir /var/log/inmanta

chown -R inmanta:inmanta /var/lib/inmanta
chown -R inmanta:inmanta /var/log/inmanta

systemctl daemon-reload
systemctl start inmanta-server
systemctl enable inmanta-server

#patch up hosts, for agent autostart
echo "192.168.33.101 vm1" >> /etc/hosts
echo "192.168.33.102 vm2" >> /etc/hosts

#set keys for agent access
cp /vagrant/vagrant-master /root/.ssh/id_rsa
mkdir /var/lib/inmanta/.ssh
cp /vagrant/vagrant-master /var/lib/inmanta/.ssh/id_rsa
cat > /var/lib/inmanta/.ssh/config <<EOF
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
EOF
chmod 600 /var/lib/inmanta/.ssh/config
chown inmanta -R /var/lib/inmanta/.ssh

# Install the dashboard
mkdir -p /usr/share/inmanta/dashboard
tar xvzf /vagrant/dist.tgz --strip-components=1 -C /usr/share/inmanta/dashboard
