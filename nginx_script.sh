#!/bin/bash
hosts=(site1.com site2.com site3.com)
nginx_path="/etc/nginx/sites-available/"
nginx_path_enabled="/etc/nginx/sites-enabled/"
nginx_ssl_path="/etc/nginx/ssl"
nginx_ssl_crt="ssl-k.crt"
nginx_ssl_key="ssl-k.key"
proxy_set_header_host="$""host"
proxy_set_header_remote="$""remote_addr"
request_uri="$""request_uri"
ip_vm="192.168.56.110"
result=""


for (( i = 0; i < "${#hosts[*]}"; i++ ))
do

info_https=$(cat <<EOF

server {
        listen 443 ssl;
        listen [::]:443 ssl;

	ssl_certificate ${nginx_ssl_path}/${nginx_ssl_crt};
        ssl_certificate_key ${nginx_ssl_path}/${nginx_ssl_key};
        
	server_name www.${hosts[i]} ${hosts[i]};

	root /var/www/${hosts[i]};
        index index.php index.html index.htm index.nginx-debian.html;


        location / {
                proxy_pass http://${hosts[i]}:8080;
		#proxy_set_header Host $proxy_set_header_host;
                #proxy_set_header X-Real_IP $proxy_set_header_remote;
        }
}
EOF
)


result+="$info_https"
done

info_http=$(cat <<EOF

server {
        listen 80 default_server;
        server_name ${hosts[@]};
        return 301 https://${ip_vm};
}
EOF
)

result+="$info_http"

if ! [ -d "${nginx_ssl_path}" ]; then
  sudo mkdir "${nginx_ssl_path}"
  sudo chmod 700 "${nginx_ssl_path}"
  if ! [ -f "${nginx_ssl_path}/${nginx_ssl_key}"]; then
    sudo touch "${nginx_ssl_path}/${nginx_ssl_key}"
  fi
  if ! [ -f "${nginx_ssl_path}/${nginx_ssl_crt}"]; then
    sudo touch "${nginx_ssl_path}/${nginx_ssl_key}"
  fi
  sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "${nginx_ssl_path}/${nginx_ssl_key}" -out "${nginx_ssl_path}/${nginx_ssl_crt}"
fi
if  [ -f "${nginx_path_enabled}default" ]; then
  sudo rm -f "${nginx_path_enabled}default"
fi
if  [ -f "${nginx_path}default" ]; then
  sudo rm "${nginx_path}default"
fi
if  [ -f "${nginx_path}https" ]; then
  if diff -b -w -B <(echo "$result") https >/dev/null; then
  echo "variable and file are equal"
  fi
else
  sudo touch "${nginx_path}https"
  echo "$result" > "${nginx_path}https"
  sudo ln -s "${nginx_path}https" "${nginx_path_enabled}https"
  sudo systemctl restart nginx.service
fi
