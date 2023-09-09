#!/bin/bash
hosts=(site1.com site2.com site3.com)
#apache_path="/etc/apache2/sites-available/"
apache_path="/home/runner/"
result=0

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
  if diff -b -w -B <(echo "$info_apache") "${apache_path}${hosts[i]}.conf" >/d$
    echo "file equal"
  else
    echo "$info_apache" > "${apache_path}${hosts[i]}.conf"
  fi
done

