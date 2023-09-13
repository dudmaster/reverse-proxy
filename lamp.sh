#!/bin/bash

DB_NAMES=(wp_db1 wp_db2 wp_db3)
DB_USERS=(wp_user1 wp_user2 wp_user3)

if ! dpkg -l | grep -E 'nginx|apache2|php|mysql-server|php-mysql'; then
    sudo apt update
    sudo apt install -y nginx apache2 php php-mysql mysql-server
fi

for (( i = 0; i < "${#DB_NAMES[*]}"; i++ ))
do
  if ! mysql -uroot -e "USE $DB_NAMES[i]" 2>/dev/null; then
    mysql -uroot -e "CREATE DATABASE ${DB_NAMES[i]};"
  fi
  if ! mysql -uroot -e "SELECT User FROM mysql.user WHERE User='$DB_USERS[i]'" | grep "$DB_USER"; then
    mysql -uroot -e "CREATE USER '${DB_USERS[i]}'@'localhost' IDENTIFIED BY 'password';"
    mysql -uroot -e "GRANT ALL PRIVILEGES ON ${DB_NAMES[i]}.* TO '${DB_USERS[i]}'@'localhost';"
    mysql -uroot -e "FLUSH PRIVILEGES;"
  fi
done
