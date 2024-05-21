#!/bin/bash
# Install dependencies
sudo yum update -y
sudo yum install -y golang git
sudo yum install -y certbot python3-certbot-nginx

# Clone the repository
cd /home/ec2-user
git clone https://github.com/T-unity/socket

# Run the Go app
cd /home/ec2-user/socket/web_socket/server
go mod edit -module=example.com/mod
go get github.com/gorilla/websocket
# go mod tidy
# go build -o websocket-server main.go
# ./websocket-server &
go run main.go

# Ensure the server starts on reboot
# echo '@reboot cd /home/ec2-user/socket/web_socket/server && ./websocket-server &' | crontab -



# Nginx configuration
# Enable and start nginx
sudo yum install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Set correct permissions
sudo chown -R nginx:nginx /home/ec2-user/socket/web_socket/client
sudo chmod 755 /home
sudo chmod 755 /home/ec2-user
sudo chmod 755 /home/ec2-user/socket
sudo chmod 755 /home/ec2-user/socket/web_socket
sudo chmod -R 755 /home/ec2-user/socket/web_socket/client

sudo bash -c 'cat <<EOF > /etc/nginx/conf.d/web_socket.conf
server {
    listen 80;
    listen 443 ssl;
    server_name socket.gynga.org;

    ssl_certificate /etc/letsencrypt/live/socket.gynga.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/socket.gynga.org/privkey.pem;

    location / {
        root /home/ec2-user/socket/web_socket/client;
        index main.html;
        autoindex on;
    }

    location /ws {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
    }
}
EOF'

# Obtain SSL certificate and configure Nginx for HTTPS
sudo certbot --nginx -d socket.gynga.org --non-interactive --agree-tos --register-unsafely-without-email

# Restart nginx to apply the configuration
# sudo systemctl restart nginx
sudo systemctl restart nginx.service
