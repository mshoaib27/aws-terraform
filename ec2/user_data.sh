#!/bin/bash
set -e
# Update the system
apt-get update -y
# Install software-properties-common for adding repositories
apt-get install -y software-properties-common
# Install NFS utilities for EFS mounting
apt-get install -y nfs-common
# Add the repository for PHP 7.4
add-apt-repository ppa:ondrej/php -y
apt-get update -y
# Install Apache and PHP 7.4 with dependencies
apt-get install -y apache2 php7.4 libapache2-mod-php7.4 php7.4-cli php7.4-common php7.4-mysql php7.4-xml php7.4-curl php7.4-mbstring
# Enable Apache mods and restart the service
a2enmod php7.4
systemctl restart apache2
# Enable Apache to start on boot
systemctl enable apache2
# Create /data directory
mkdir -p /data
chmod 755 /data
# Mount EFS to /data
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_dns_name}:/ /data
# Add EFS mount to fstab for persistent mounting
echo "${efs_dns_name}:/ /data nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" | tee -a /etc/fstab
# Verify installation and mount
apache2 -v
php -v
mount | grep /data
