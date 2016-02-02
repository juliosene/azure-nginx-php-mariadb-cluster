#!/bin/bash
# Install Nginx + php-fpm + apc cache for Ubuntu and Debian distributions
cd ~
# apt-get update
# apt-get -fy dist-upgrade
# apt-get -fy upgrade
apt-get install lsb-release bc
REL=`lsb_release -sc`
DISTRO=`lsb_release -is | tr [:upper:] [:lower:]`
NCORES=` cat /proc/cpuinfo | grep cores | wc -l`
WORKER=`bc -l <<< "4*$NCORES"`

wget http://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key
add-apt-repository "deb http://nginx.org/packages/$DISTRO/ $REL nginx"
add-apt-repository "deb-src http://nginx.org/packages/$DISTRO/ $REL nginx"

apt-get update

apt-get install -y -f cifs-utils

apt-get install -fy nginx
apt-get install -fy python-software-properties
LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php
apt-get -y update
apt-get install php7.0 php7.0-fpm php7.0-mysql -y
apt-get install -fy php-apc php7.0-gd
apt-get --purge autoremove -y
# replace www-data to nginx into /etc/php/7.0/fpm/pool.d/www.conf
sed -i 's/www-data/nginx/g' /etc/php/7.0/fpm/pool.d/www.conf
service php7.0-fpm restart
#
# backup default Nginx configuration
mkdir /etc/nginx/conf-bkp
cp /etc/nginx/conf.d/default.conf /etc/nginx/conf-bkp/default.conf
cp /etc/nginx/nginx.conf /etc/nginx/nginx-conf.old
#
# Replace nginx.conf
#
wget https://raw.githubusercontent.com/juliosene/azure-nginx-php-mariadb-cluster/master/files/nginx.conf

sed -i "s/#WORKER#/$WORKER/g" nginx.conf
mv nginx.conf /etc/nginx/

# replace Nginx default.conf
#
wget https://raw.githubusercontent.com/juliosene/azure-nginx-php-mariadb-cluster/master/files/default.conf

#sed -i "s/#WORKER#/$WORKER/g" nginx.conf
mv default.conf /etc/nginx/conf.d/

# Memcache client installation
# apt-get install -fy php-pear
# apt-get install -fy php7.0-dev
# printf "\n" |pecl install -f memcache

apt-get install -y php7.0-dev git pkg-config build-essential libmemcached-dev
cd ~
git clone https://github.com/php-memcached-dev/php-memcached.git
cd php-memcached
git checkout php7
phpize
./configure --disable-memcached-sasl
make
sudo make install
#
wget https://raw.githubusercontent.com/juliosene/azure-nginx-php-mariadb-cluster/master/files/memcache.ini

#sed -i "s/#WORKER#/$WORKER/g" memcache.ini
mv memcache.ini /etc/php/mods-available/

ln -s /etc/php/mods-available/memcache.ini  /etc/php/7.0/fpm/conf.d/20-memcache.ini

#
# Edit default page to show php info
#
#mv /usr/share/nginx/html/index.html /usr/share/nginx/html/index.php
mkdir /usr/share/nginx/html/web
echo -e "<html><title>Azure Nginx PHP</title><body><h2>Your Nginx and PHP are running!</h1></br>\n<?php\nphpinfo();\n?></body>" > /usr/share/nginx/html/web/index.php
#
# Services restart
#
service php7.0-fpm restart
service nginx restart
