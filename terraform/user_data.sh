#!/bin/bash
# Install dependencies
sudo yum update -y
sudo yum install -y golang git nginx

# Clone the repository
cd /home/ec2-user
git clone https://github.com/T-unity/socket

# Run the Go app
cd /home/ec2-user/socket/
sudo go mod init example.com/m
sudo go mod tidy
cd /home/ec2-user/socket/web_socket/server
sudo go mod edit -module=example.com/mod
sudo go get github.com/gorilla/websocket
sudo go run main.go &

# Ensure the server starts on reboot (if necessary, uncomment and adjust as needed)
# echo '@reboot cd /home/ec2-user/socket/web_socket/server && ./websocket-server &' | crontab -

# Nginx configuration
# Enable and start nginx
sudo systemctl enable nginx

# Set correct permissions
sudo chown -R nginx:nginx /home/ec2-user/socket/web_socket/client
sudo chmod 755 /home
sudo chmod 755 /home/ec2-user
sudo chmod 755 /home/ec2-user/socket
sudo chmod 755 /home/ec2-user/socket/web_socket
sudo chmod -R 755 /home/ec2-user/socket/web_socket/client

# Start nginx
sudo systemctl start nginx

# Temporary Nginx configuration without SSL
sudo bash -c 'cat <<EOF > /etc/nginx/conf.d/web_socket.conf
server {
    listen 80;
    server_name socket.gynga.org;

    location / {
        root /home/ec2-user/socket/web_socket/client;
        index main.html;
        autoindex on;
    }

    location /ws {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host \$host;
    }
}
EOF'

sudo systemctl restart nginx.service
