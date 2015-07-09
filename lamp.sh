# Variables
APPENV=local
DBHOST=localhost
DBNAME=devdb
DBUSER=root
DBPASSWD=1234

sudo apt-get update

sudo apt-get install -y vim-nox curl python-software-properties build-essential git
sudo add-apt-repository -y ppa:ondrej/php5

sudo apt-get update

# Installing MySQL with PhpMyAdmin
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none"

apt-get -y install mysql-server phpmyadmin

mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'"
 
# Installing php5 with mcrypt and other packages
sudo apt-get install -y php5 apache2 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt php5-readline mysql-server-5.5 php5-mysql git-core php5-xdebug

cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

# Configuring Apache with PhpMyAdmin
echo "Include /etc/phpmyadmin/apache.conf" | sudo tee -a /etc/apache2/apache2.conf

# Enabling rewrite module
sudo a2enmod rewrite

# Enabling all php errors
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini
sed -i "s/disable_functions = .*/disable_functions = /" /etc/php5/cli/php.ini

# Restarting apache2
sudo service apache2 restart

# Installing Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
