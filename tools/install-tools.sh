#!/bin/bash
#
cd ~
apt-get install apache2-utils -f -y

htpasswd -c -b /usr/share/nginx/html/.htpasswd $1 $2

wget https://raw.githubusercontent.com/juliosene/azure-nginx-php-mariadb-cluster/master/tools/tools.conf
mv tools.conf /etc/nginx/conf.d/

mkdir /usr/share/nginx/html/tools
cd /usr/share/nginx/html/tools
# Download and install PHP File Manager & phpmyadmin
wget http://sourceforge.net/projects/phpfm/files/phpFileManager/version%200.9.8/phpFileManager-0.9.8.zip/download
unzip download
mkdir filemanager
mv index.php ./filemanager/
wget https://files.phpmyadmin.net/phpMyAdmin/4.5.3.1/phpMyAdmin-4.5.3.1-all-languages.zip
unzip phpMyAdmin-4.5.3.1-all-languages.zip
mv phpMyAdmin-4.5.3.1-all-languages phpmyadmin

service nginx reload


