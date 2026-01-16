#!/bin/bash
apt-get update
apt-get install -y nginx
echo "Hello from Azure VM" > /var/www/html/index.html