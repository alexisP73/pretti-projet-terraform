#!/bin/bash
apt update -y
apt install -y nginx
systemctl enable nginx
echo "<h1>$(hostname)</h1>" > /var/www/html/index.html
