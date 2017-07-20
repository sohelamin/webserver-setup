#!/bin/bash
# ********************************
# Project: LAMP Setup Script
# Author: Sohel Amin
# URL: http://www.appzcoder.com
# ********************************

# Variables
DBNAME=devdb
DBUSER=root
DBPASSWD=1234

sudo apt-get update

sudo apt-get install python-software-properties
sudo add-apt-repository -y ppa:ondrej/php

# Installing curl, git apache2
sudo apt-get install -y curl git apache2

sudo apt-get update

# Installing MySQL with PhpMyAdmin
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none"

sudo apt-get install mysql-server phpmyadmin

mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'"

# Configuring xdebug for php7.1
cat << EOF | sudo tee -a /etc/php/7.1/apache2/php.ini
# Added for xdebug
zend_extension="/usr/lib/php/20151012/xdebug.so"
xdebug.remote_enable=1
xdebug.remote_handler=dbgp
xdebug.remote_mode=req
xdebug.remote_host=127.0.0.1
xdebug.remote_port=9000
xdebug.max_nesting_level=300
EOF

# Configuring Apache with PhpMyAdmin
echo "Include /etc/phpmyadmin/apache.conf" | sudo tee -a /etc/apache2/apache2.conf

# Enabling rewrite module
sudo a2enmod rewrite

# Enabling all php errors on 7.1
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.1/apache2/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.1/apache2/php.ini
sudo sed -i "s/display_startup_errors = .*/display_startup_errors = On/" /etc/php/7.1/apache2/php.ini

# Upload limit & memory
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 1024M/" /etc/php/7.1/apache2/php.ini
sudo sed -i "s/post_max_size = .*/post_max_size = 1024M/" /etc/php/7.1/apache2/php.ini

# Making info.php file for display phpinfo
# sudo chmod 777 -R /var/www/;
# sudo printf "<?php\nphpinfo();\n?>" > /var/www/html/info.php;

# Restarting apache2
sudo service apache2 restart

# Installing Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
