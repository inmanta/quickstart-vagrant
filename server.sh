#!/bin/bash

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

dnf install -y python3-inmanta-server inmanta-dashboard python3-greenlet python3-pymongo-gridfs mongodb-server

echo "smallfiles = true" >>/etc/mongod.conf 
systemctl start mongod
systemctl enable mongod

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
