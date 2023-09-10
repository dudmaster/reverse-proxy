#!/bin/sh
DB_NAMES="wp_db1 wp_db2 wp_db3"
DB_USERS="wp_user1 wp_user2 wp_user3"
pass=password
hosts=(site1.com site2.com site3.com)
apache_path="/etc/apache2/sites-available/"
DB_NAMESw=(wp_db1 wp_db2 wp_db3)
DB_USERSw=(wp_user1 wp_user2 wp_user3)
result=0

hosts=(site1.com site2.com site3.com)
nginx_path="/etc/nginx/sites-available/"
result=""

#create 3 wordpress/add database/add change color in wordpress 
path1="/var/www/${hosts[0]}"
path2="/var/www/${hosts[1]}"
path3="/var/www/${hosts[2]}"
style_file1=$path1/wp-admin/css/colors/light/colors-rtl.css
style_file2=$path2/wp-admin/css/colors/light/colors-rtl.css
style_file3=$path3/wp-admin/css/colors/light/colors-rtl.css
redcolor="#fa0505"
greencolor="##16ed0e"
yellowcolor="#c5f005"

### DB ######################33
if ! dpkg -l | grep -E 'nginx|apache2|php|mysql-server|php-mysql'; then
    sudo apt update
    sudo apt install -y nginx apache2 php php-mysql mysql-server
fi



for DB_NAME in $DB_NAMES; do
    if ! mysql -uroot -e "USE $DB_NAME" 2>/dev/null; then
        mysql -uroot -e "CREATE DATABASE $DB_NAME;"
    fi
done

for DB_USER in $DB_USERS; do
    if ! mysql -uroot -e "SELECT User FROM mysql.user WHERE User='$DB_USER'" | grep "$DB_USER"; then
        mysql -uroot -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY 'password';"
        mysql -uroot -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
        mysql -uroot -e "FLUSH PRIVILEGES;"
    fi
done
##### apache #######
for (( i = 0; i < "${#hosts[*]}"; i++ )); do
  info_apache=$(cat << EOF
<VirtualHost *:8080>
        ServerName ${hosts[i]}
        ServerAlias www.${hosts[i]}

        ServerAdmin ${hosts[i]}-webmaster@localhost
        DocumentRoot /var/www/${hosts[i]}

        ErrorLog ${APACHE_LOG_DIR}/${hosts[i]}-error.log
        CustomLog ${APACHE_LOG_DIR}/${hosts[i]}-access.log combined
</VirtualHost>
EOF
)
  for file in "$apache_path"*; do
    filename=$(basename "$file")
    if [[ "$filename" == "${hosts[i]}.conf" ]]; then
      result=1
      echo "File ${hosts[i]}.conf was found"
    fi
  done
    if [[ "$result" = 0 ]]; then
      touch "${apache_path}${hosts[i]}.conf"
      echo "$info_apache" > "${apache_path}${hosts[i]}.conf"
      result=0
    fi
  if diff -b -w -B <(echo "$info_apache") "${apache_path}${hosts[i]}.conf" >/dev/null; then
    echo "file equal"
  else
    echo "$info_apache" > "${apache_path}${hosts[i]}.conf"
  fi
done

#### nginx ####
for (( i = 0; i < "${#hosts[*]}"; i++ ))
do
info_https=$(cat <<EOF

server {
        root /var/www/${hosts[i]};
        index index.html index.htm index.nginx-debian.html;

        server_name www.${hosts[i]} ${hosts[i]};

        listen 443 ssl;
        listen [::]:443 ssl;
        include snippets/self-signed.conf;
        include snippets/ssl-params.conf;

        location / {
                proxy_pass http://${hosts[i]}:8080;
                proxy_set_header Host $host;
                proxy_set_header X-Real_IP $remote_addr;
        }
}
EOF
)
result+="$info_https"
done

info_http=$(cat <<EOF

server {
        listen 80;
        listen [::]:80;
        server_name ${hosts[@]};
        return 301 https://$server_name$request_uri;
}
EOF
)

result+="$info_http"
if  [ -f "${nginx_path}https" ]; then
  if diff -b -w -B <(echo "$result") https >/dev/null; then
  echo "variable and file are equal"
  else
  touch "${nginx_path}https"
  echo "$result" > "${nginx_path}https"
  fi
fi

# wordpress ###########
cd /tmp && wget https://wordpress.org/latest.tar.gz
sudo tar -xvf /tmp/latest.tar.gz -C /var/www/
sudo mv /var/www/wordpress "$path1"
sudo cp -r "$path1" "$path2"
sudo cp -r "$path1" "$path3"
sudo chown -R www-data:www-data /var/www/
sudo chmod -R 755 /var/www/
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
sudo sed -i "s/database_name_here/${DB_NAMESw[0]}/" $path1/wp-config.php
sudo sed -i "s/username_here/${DB_USERSw[0]}/" $path1/wp-config.php
sudo sed -i "s/password_here/${pass}/" $path1/wp-config.php

sudo cp $path2/wp-config-sample.php $path2/wp-config.php 
sudo sed -i "s/database_name_here/${DB_NAMESw[1]}/" $path2/wp-config.php
sudo sed -i "s/username_here/${DB_USERSw[1]}/" $path2/wp-config.php
sudo sed -i "s/password_here/${pass}/" $path2/wp-config.php

sudo cp $path3/wp-config-sample.php $path3/wp-config.php 
sudo sed -i "s/database_name_here/${DB_NAMESw[2]}/" $path3/wp-config.php
sudo sed -i "s/username_here/${DB_USERSw[2]}/" $path3/wp-config.php
sudo sed -i "s/password_here/${pass}/" $path3/wp-config.php
