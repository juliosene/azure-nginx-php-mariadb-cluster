#!/bin/bash
#
SECURITY=`date +%D%A%B | md5sum| sha256sum | base64| fold -w16| head -n1`
cd ~
apt-get install apache2-utils unzip -f -y

htpasswd -c -b /usr/share/nginx/html/.htpasswd $1 $2

wget https://raw.githubusercontent.com/juliosene/azure-nginx-php-mariadb-cluster/master/tools/tools.conf
mv tools.conf /etc/nginx/conf.d/

mkdir /usr/share/nginx/html/tools
cd /usr/share/nginx/html/tools
# Download index page
wget https://raw.githubusercontent.com/juliosene/azure-nginx-php-mariadb-cluster/master/tools/index.html
#
# Download and install PHP File Manager & phpmyadmin
#
# File Manager
wget http://sourceforge.net/projects/phpfm/files/phpFileManager/version%200.9.8/phpFileManager-0.9.8.zip/download
unzip download
mkdir filemanager
mv index.php filemanager/
mv LICENSE.html filemanager/
#
# PHPMyAdmin
wget https://files.phpmyadmin.net/phpMyAdmin/4.5.3.1/phpMyAdmin-4.5.3.1-all-languages.zip
unzip phpMyAdmin-4.5.3.1-all-languages.zip
mv phpMyAdmin-4.5.3.1-all-languages phpmyadmin

rm -Rf download phpMyAdmin-4.5.3.1-all-languages.zip

# Config file to PHPMyAdmin
wget https://raw.githubusercontent.com/juliosene/azure-nginx-php-mariadb-cluster/master/tools/config.inc.php
mv config.inc.php /usr/share/nginx/html/tools/phpmyadmin/
sed -i "s/#SECURITY#/$SECURITY/g" /usr/share/nginx/html/tools/phpmyadmin/config.inc.php
#
# Restart web server
service nginx restart


