#!/bin/bash
hosts=(site1.com site2.com site3.com)
apache_path="/etc/apache2/sites-available/"
apache_ports="/etc/apache2/ports.conf"
apache_log_dir="/var/log/apache2"
result=0

for (( i = 0; i < "${#hosts[*]}"; i++ )); do
  info_apache=$(cat << EOF
<VirtualHost *:8080>
        ServerName ${hosts[i]}
        ServerAlias www.${hosts[i]}

        ServerAdmin ${hosts[i]}-webmaster@localhost
        DocumentRoot /var/www/${hosts[i]}

        ErrorLog $apache_log_dir/${hosts[i]}-error.log
        CustomLog $apache_log_dir/${hosts[i]}-access.log combined
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

    if ! grep -q "Listen 8080" "${apache_ports}"; then
      sudo sed -i 's/Listen 80/Listen 8080/' "${apache_ports}"
    fi
    if [[ "$result" = 0 ]]; then
      touch "${apache_path}${hosts[i]}.conf"
      echo "$info_apache" > "${apache_path}${hosts[i]}.conf"
      sudo a2dissite 000-default.conf
      sudo a2ensite "${hosts[i]}"
      result=0
      sudo systemctl restart apache2
    fi
  if diff -b -w -B <(echo "$info_apache") "${apache_path}${hosts[i]}.conf" >/dev/null; then
    echo "file equal"
  else
    echo "$info_apache" > "${apache_path}${hosts[i]}.conf"
  fi
done
