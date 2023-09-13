#!/bin/bash






#create 3 wordpress/add database/add change color in wordpress 
hosts=(site1.com site2.com site3.com)
path1="/var/www/html/${hosts[0]}"
path2="/var/www/html/${hosts[1]}"
path3="/var/www/html/${hosts[2]}"
style_file1=$path1/wp-admin/css/colors/light/colors-rtl.css
style_file2=$path2/wp-admin/css/colors/light/colors-rtl.css
style_file3=$path3/wp-admin/css/colors/light/colors-rtl.css
redcolor="#fa0505"
greencolor="##16ed0e"
yellowcolor="#c5f005"

cd /tmp && wget https://wordpress.org/latest.tar.gz
sudo tar -xvf /tmp/latest.tar.gz -C /var/www/html
sudo mv /var/www/html/wordpress "$path1"
sudo cp -r "$path1" "$path2"
sudo cp -r "$path1" "$path3"
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
sudo mkdir $path1/wp-content/uploads
sudo mkdir $path2/wp-content/uploads
sudo mkdir $path3/wp-content/uploads
sudo chown -R www-data:www-data $path1/wp-content/uploads/
sudo chown -R www-data:www-data $path2/wp-content/uploads/
sudo chown -R www-data:www-data $path3/wp-content/uploads/

sudo sed -i "s/background: #f5f5f5;/background: ${redcolor};/g" $style_file1
sudo sed -i "s/background: #f5f5f5;/background: ${greencolor};/g" $style_file2
sudo sed -i "s/background: #f5f5f5;/background: ${yellowcolor};/g" $style_file3

sudo cp $path1/wp-config-sample.php $path1/wp-config.php 
sudo sed -i "s/database_name_here/${name_wp}/" $path1/wp-config.php
sudo sed -i "s/username_here/${name_wp}/" $path1/wp-config.php
sudo sed -i "s/password_here/${pass_wp}/" $path1/wp-config.php

sudo cp $path2/wp-config-sample.php $path2/wp-config.php 
sudo sed -i "s/database_name_here/${name_wp}/" $path2/wp-config.php
sudo sed -i "s/username_here/${name_wp}/" $path2/wp-config.php
sudo sed -i "s/password_here/${pass_wp}/" $path2/wp-config.php

sudo cp $path3/wp-config-sample.php $path3/wp-config.php 
sudo sed -i "s/database_name_here/${name_wp}/" $path3/wp-config.php
sudo sed -i "s/username_here/${name_wp}/" $path3/wp-config.php
sudo sed -i "s/password_here/${pass_wp}/" $path3/wp-config.php
