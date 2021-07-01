#!/bin/bash

apt-get update -y
apt-get dist-upgrade -y
apt install mc curl git nginx apache2-utils -y

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 16

npm i pm2 -g   
git clone https://github.com/Superalgos/Superalgos.git
cd Superalgos
node setup noShortcuts
pm2 start run.js -- minMemo noBrowser
pm2 startup
pm2 save

touch /etc/nginx/htpasswd

cd /etc/nginx

echo enter new user login:
read login

htpasswd /etc/nginx/htpasswd $login

echo "server {
        listen 80 default_server;
        listen [::]:80 default_server;
        root /var/www/html;
        index index.html index.htm index.nginx-debian.html;

        server_name _;
       
        location / {
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header Host \$http_host;
                proxy_pass http://127.0.0.1:34248;
                auth_basic \"Restricted\";
                auth_basic_user_file /etc/nginx/htpasswd;
            }     
         
}" > /etc/nginx/sites-available/default

systemctl reload nginx

iptables -L -n --line-numbers

iptables -A INPUT -p tcp -s 127.0.0.1 --dport 34248 -j ACCEPT
iptables -A INPUT -p tcp --dport 34248 -j DROP
