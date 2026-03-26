#!/bin/bash
apt update -y
apt install nginx -y
service nginx start
cp /tmp/index.html /var/www/html/index.html
