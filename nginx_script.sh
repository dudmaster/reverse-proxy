#!/bin/bash
hosts=(site1.com site2.com site3.com)
#nginx_path="/etc/nginx/sites-available/"
ngnix_path="/home/pavel/"
result=""

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