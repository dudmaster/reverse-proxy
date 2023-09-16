#!/bin/bash


#create 3 wordpress/add database/add change color in wordpress 

DB_NAMES=(wp_db1 wp_db2 wp_db3)
DB_USERS=(wp_user1 wp_user2 wp_user3)
hosts=(site1.com site2.com site3.com)
colors=("#FF0000" "#00FF00" "#0000FF")
path="/var/www"
default_color="#f5f5f5"
default_path_color="wp-admin/css/colors/light/colors-rtl.css"
wp_content="wp-content/uploads"
wp_config_simple="wp-config-sample.php"
wp_config="wp-config.php"
password='password'
wp_siteurl="'WP_SITEURL'"
wp_home="'WP_HOME'"
wget https://wordpress.org/latest.tar.gz -P /tmp/
sudo tar -xvf /tmp/latest.tar.gz -C $path
wp_ser="$""_SERVER"
https_wp=$(cat << EOF
if ( $wp_ser['HTTP_X_FORWARDED_PROTO'] == 'https' )
{
        $wp_ser['HTTPS']       = 'on';
    $wp_ser['SERVER_PORT'] = '443';
        define('FORCE_SSL_ADMIN', true);
}
 
if ( isset($wp_ser['HTTP_X_FORWARDED_HOST']) )
{
        $wp_ser['HTTP_HOST'] = $wp_ser['HTTP_X_FORWARDED_HOST'];
}
EOF
)

sudo touch https_wp.txt
sudo chmod 777 https_wp.txt
echo "$https_wp" > https_wp.txt </dev/null

for (( i = 0; i < "${#hosts[*]}"; i++ ))
do
  cp -r $path/wordpress $path/${hosts[i]}
  mkdir $path/${hosts[i]}/$wp_content
  cp $path/${hosts[i]}/$wp_config_simple $path/${hosts[i]}/$wp_config 
  sudo sed -i "s/database_name_here/${DB_NAMES[i]}/" $path/${hosts[i]}/$wp_config
  sudo sed -i "s/username_here/${DB_USERS[i]}/" $path/${hosts[i]}/$wp_config
  sudo sed -i "s/password_here/${password}/" $path/${hosts[i]}/$wp_config
  sudo sed -i "s/background: $default_color;/background: ${colors[i]};/g" $path/${hosts[i]}/$default_path_color
  sudo sed -i '1 a\define( '$wp_siteurl', '"'https://www.${hosts[i]}'"' );' $path/${hosts[i]}/$wp_config
  sudo sed -i '2 a\define( '$wp_home', '"'https://www.${hosts[i]}'"' );' $path/${hosts[i]}/$wp_config
  sudo sed -i "3r https_wp.txt" $path/${hosts[i]}/$wp_config
done

sudo chown -R www-data:www-data $path/
sudo chmod -R 755 $path/
