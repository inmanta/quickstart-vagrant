#!/bin/bash

if [ -z "$rpm_repo" ]
then
  rpm_repo="stable"
fi

##################################
### Configure yum repositories ###
##################################

# Pin mirror to prevent timeouts to metadata service
yum_repo_file="/etc/yum.repos.d/CentOS-Base.repo"
# Comment out mirrorlist lines
sed -i '/^mirrorlist=/s/^/#/' ${yum_repo_file}
full_centos_version=$(cut -d ' ' -f 4 /etc/centos-release)
for repo_name in "os" "updates" "extras" "centosplus"; do
   old_baseurl_line="^#baseurl=http://mirror.centos.org/centos/\$releasever/${repo_name}/\$basearch/"
   new_baseurl_line="baseurl=http://centos.mirror.nucleus.be/${full_centos_version}/${repo_name}/\$basearch/"
   # Set specific mirror
   sed -i "s|${old_baseurl_line}|${new_baseurl_line}|" ${yum_repo_file}
done
yum clean all

yum install -y epel-release
cat > /etc/yum.repos.d/inmanta_oss_dev.repo <<EOF
[inmanta-oss-$rpm_repo]
name=Inmanta OSS $rpm_repo
baseurl=https://pkg.inmanta.com/inmanta-oss-$rpm_repo/el7/
gpgcheck=1
gpgkey=https://pkg.inmanta.com/inmanta-oss-$rpm_repo/inmanta-oss-$rpm_repo-public-key
repo_gpgcheck=1
enabled=1
enabled_metadata=1
EOF

########################
### Install packages ###
########################

rpm -i https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm
yum install -y python3-inmanta python3-inmanta-server python3-inmanta-agent mongodb-server postgresql10-server

########################
### Setup PostgreSQL ###
########################

# Init PostgreSQL database
su - postgres -c '/usr/pgsql-10/bin/initdb /var/lib/pgsql/10/data'

# start PostgreSQL
systemctl start postgresql-10
systemctl enable postgresql-10

# Create inmanta database in PostgreSQL
su - postgres -c "psql -U postgres -c 'create database inmanta;'"

####################
## Setup MongoDB ###
####################

#optimize mongo for small db and fast start
echo "smallfiles = true" >>/etc/mongod.conf

#start mongo
systemctl start mongod
systemctl enable mongod

###########################
## Setup Inmanta server ###
###########################

# configure inmanta
sed -i "s/\[server\]/\[server\]\nagent_autostart = *\n/g" /etc/inmanta/server.cfg

# start inmanta server
systemctl enable inmanta-server
systemctl start inmanta-server

#################################################################
### Make sure that Inmanta server can login on VM1 and on VM2 ###
#################################################################

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

