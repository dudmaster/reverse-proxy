!/bin/sh

if ! dpkg -l | grep -E 'nginx|apache2|php|mysql-server|php-mysql'; then
    sudo apt update
    sudo apt install -y nginx apache2 php php-mysql mysql-server
fi

DB_NAMES="wp_db1 wp_db2 wp_db3"
DB_USERS="wp_user1 wp_user2 wp_user3"

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
