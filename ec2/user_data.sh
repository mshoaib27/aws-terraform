#!/bin/bash

# Logging setup
exec > /var/log/user-data.log 2>&1
set -x

echo "[$(date)]Starting user_data script"

# Update the system
echo "[$(date)] Updating system packages..."
apt-get update -y || { echo "Failed to update apt"; exit 1; }

# Install required packages
echo "[$(date)] Installing software-properties-common..."
apt-get install -y software-properties-common || { echo "Failed to install software-properties-common"; exit 1; }

echo "[$(date)] Installing NFS utilities..."
apt-get install -y nfs-common || { echo "Failed to install nfs-common"; exit 1; }

# Add PHP repository
echo "[$(date)] Adding PHP repository..."
add-apt-repository ppa:ondrej/php -y || { echo "Failed to add PHP repository"; exit 1; }
apt-get update -y || { echo "Failed to update after adding PHP repo"; exit 1; }

# Install Apache and PHP 7.4 with all required modules
echo "[$(date)] Installing Apache and PHP 7.4 with all modules..."
apt-get install -y \
  apache2 \
  php7.4 \
  libapache2-mod-php7.4 \
  php7.4-cli \
  php7.4-common \
  php7.4-apcu \
  php7.4-bcmath \
  php7.4-calendar \
  php7.4-curl \
  php7.4-dom \
  php7.4-exif \
  php7.4-fileinfo \
  php7.4-filter \
  php7.4-ftp \
  php7.4-gd \
  php7.4-gettext \
  php7.4-hash \
  php7.4-iconv \
  php7.4-igbinary \
  php7.4-json \
  php7.4-libxml \
  php7.4-mbstring \
  php7.4-mysql \
  php7.4-mysqli \
  php7.4-mysqlnd \
  php7.4-openssl \
  php7.4-pcntl \
  php7.4-pcre \
  php7.4-pdo \
  php7.4-pdo-mysql \
  php7.4-phar \
  php7.4-posix \
  php7.4-readline \
  php7.4-redis \
  php7.4-reflection \
  php7.4-session \
  php7.4-shmop \
  php7.4-simplexml \
  php7.4-sockets \
  php7.4-sodium \
  php7.4-spl \
  php7.4-standard \
  php7.4-sysvmsg \
  php7.4-sysvsem \
  php7.4-sysvshm \
  php7.4-tokenizer \
  php7.4-xml \
  php7.4-xmlreader \
  php7.4-xmlwriter \
  php7.4-xsl \
  php7.4-opcache \
  php7.4-zip \
  php7.4-zlib \
  || { echo "Failed to install Apache/PHP"; exit 1; }

# Enable Apache modules
echo "[$(date)] Enabling Apache PHP module..."
a2enmod php7.4 || { echo "Failed to enable php7.4 module"; exit 1; }

echo "[$(date)] Restarting Apache..."
systemctl restart apache2 || { echo "Failed to restart Apache"; exit 1; }

echo "[$(date)] Enabling Apache on boot..."
systemctl enable apache2 || { echo "Failed to enable Apache on boot"; exit 1; }

# Create /data directory
echo "[$(date)] Creating /data directory..."
mkdir -p /data
chmod 755 /data

# Wait for EFS DNS to resolve
echo "[$(date)] Waiting for EFS DNS resolution: ${efs_dns_name}"
for i in {1..30}; do
  if nslookup ${efs_dns_name} > /dev/null 2>&1; then
    echo "[$(date)] EFS DNS resolved successfully"
    break
  fi
  if [ $i -eq 30 ]; then
    echo "[$(date)] ERROR: EFS DNS failed to resolve after 30 attempts"
    exit 1
  fi
  sleep 2
done

# Mount EFS to /data
echo "[$(date)] Mounting EFS to /data..."
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_dns_name}:/ /data || { echo "Failed to mount EFS"; exit 1; }

# Add EFS mount to fstab for persistent mounting
echo "[$(date)] Adding EFS to fstab..."
echo "${efs_dns_name}:/ /data nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" | tee -a /etc/fstab

# Verify installation and mount
echo "[$(date)] Verifying Apache installation..."
apache2 -v || { echo "Failed to verify Apache"; exit 1; }

echo "[$(date)] Verifying PHP installation..."
php -v || { echo "Failed to verify PHP"; exit 1; }

echo "[$(date)] Listing installed PHP modules..."
php -m

echo "[$(date)] Verifying EFS mount..."
mount | grep /data || { echo "Failed to verify EFS mount"; exit 1; }

echo "[$(date)] User_data script completed successfully!"
