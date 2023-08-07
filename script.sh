#!/bin/bash






#create 3 wordpress/add database/add change color in wordpress 
hosts=(site1.com site2.com site3.com)
style_file1=/var/www/html/site1.com/wp-admin/css/colors/light/colors-rtl.css
style_file2=/var/www/html/site2.com/wp-admin/css/colors/light/colors-rtl.css
style_file3=/var/www/html/site3.com/wp-admin/css/colors/light/colors-rtl.css
redcolor="#fa0505"
greencolor="##16ed0e"
yellowcolor="#c5f005"

cd /tmp && wget https://wordpress.org/latest.tar.gz
sudo tar -xvf /tmp/latest.tar.gz -C /var/www/html
sudo mv /var/www/html/wordpress /var/www/html/${hosts[0]}
sudo cp -r /var/www/html/${hosts[0]} /var/www/html/${hosts[1]}
sudo cp -r /var/www/html/${hosts[0]} /var/www/html/${hosts[2]}
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
sudo mkdir /var/www/html/${hosts[0]}/wp-content/uploads
sudo mkdir /var/www/html/${hosts[1]}/wp-content/uploads
sudo mkdir /var/www/html/${hosts[2]}/wp-content/uploads
sudo chown -R www-data:www-data /var/www/html/${hosts[0]}/wp-content/uploads/
sudo chown -R www-data:www-data /var/www/html/${hosts[1]}/wp-content/uploads/
sudo chown -R www-data:www-data /var/www/html/${hosts[2]}/wp-content/uploads/

sudo sed -i "s/background: #f5f5f5;/background: ${redcolor};/g" $style_file1
sudo sed -i "s/background: #f5f5f5;/background: ${greencolor};/g" $style_file2
sudo sed -i "s/background: #f5f5f5;/background: ${yellowcolor};/g" $style_file3

sudo cp /var/www/html/site1.com/wp-config-sample.php /var/www/html/site1.com/wp-config.php 
sudo sed -i "s/database_name_here/${name_wp}/" /var/www/html/site1.com/wp-config.php
sudo sed -i "s/username_here/${name_wp}/" /var/www/html/site1.com/wp-config.php
sudo sed -i "s/password_here/${pass_wp}/" /var/www/html/site1.com/wp-config.php

sudo cp /var/www/html/site2.com/wp-config-sample.php /var/www/html/site2.com/wp-config.php 
sudo sed -i "s/database_name_here/${name_wp}/" /var/www/html/site2.com/wp-config.php
sudo sed -i "s/username_here/${name_wp}/" /var/www/html/site2.com/wp-config.php
sudo sed -i "s/password_here/${pass_wp}/" /var/www/html/site2.com/wp-config.php
