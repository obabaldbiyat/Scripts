#!/bin/bash
echo ...... installation mariadb client -php -apache2 -wordpress.........
sudo apt update 
sudo apt upgrade
sudo apt install apache2
sudo apt install mariadb-client
sudo apt install php php-mysql
cd /tmp 
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xvf latest.tar.gz
sudo cp -R wordpress /var/www/html/
sudo chown -R www-data:www-data /var/www/html/wordpress/
sudo chmod -R 755 /var/www/html/wordpress/
sudo mkdir /var/www/html/wordpress/wp-content/uploads
sudo chown -R www-data:www-data /var/www/html/wordpress/wp-content/uploads/
echo 
echo ...........connection to mariaDB and add database..........
echo 
echo UserName de serveur mariaDB ex:user@debmaria?
read servername
echo password?
read Adminpass
echo host name ex:debmaria.mariadb.database.azure.com?
read hostname
echo database name ?
read namedatabase
echo 
mariadb --user=$servername --password=$Adminpass --host=$hostname -e "create database $namedatabase;"
sudo cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
echo 
echo ............create wp-config.php and add info.........
echo 
echo database_wardpress_name ?
read database_wp_name_here
echo username_here?
read username
echo password ?
read password_here
echo localhostname ?
read localhostname
sudo sed -i "s/database_name_here/$database_wp_name_here/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/username_here/$username/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/password_here/$password_here/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/localhost/$localhostname/" /var/www/html/wordpress/wp-config.php