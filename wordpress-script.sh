sudo apt update && sudo apt upgrade
sudo apt install apache2
sudo apt install mariadb-client
sudo apt install php php-mysql
#Step 5: Install WordPress CMS
cd /tmp 
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xvf latest.tar.gz
sudo cp -R wordpress /var/www/html/
sudo chown -R www-data:www-data /var/www/html/wordpress/
sudo chmod -R 755 /var/www/html/wordpress/
sudo mkdir /var/www/html/wordpress/wp-content/uploads
sudo chown -R www-data:www-data /var/www/html/wordpress/wp-content/uploads/

#echo Nom du serveur mariaDB?
#read servernam
#echo password?
#read Adminpass
#echo host name ?
#read hostname
#echo database?
#read namedatabase
#mariadb --user=$servername --password=$Adminpass --host=$hostname
#CREATE DATABASE $namedatabase;
#exit

sudo cp ./var/html/wordpress/wp-config-simple.php ./var/html/wordpress/wp-config.php

echo database_wp_name ?
read database_wp_name_here
echo username_here?
read username
echo password ?
read password_here
echo localhostname ?
read localhostname
sudo sed -i "s/database_name_here/$database_wp_name_here/" wp-config.php
sudo sed -i "s/username_here/$username/" wp-config.php
sudo sed -i "s/password_here/$password_here/" wp-config.php
sudo sed -i "s/localhost/$localhostname/" wp-config.php