#!/bin/bash
# Copyright (c) 2018, Oracle and/or its affiliates. All rights reserved.
set -e -x

# Install NGINX (nginx-1.12.2-2.el7.x86_64)
# The yum repo 'ol7_developer_EPEL' has been configured and enabled in Oracle 
# Linux Image 7 which can just run the 'yum install' command to install the nginx 
sudo yum install -y nginx-1.12.2-2.el7.x86_64

# Config nginx server Http Port
sudo sed -i -E "s/(listen.+)80(.+default_server;)/\1${http_port}\2/g" /etc/nginx/nginx.conf 

# Start Nginx
sudo service nginx start 

# Set httpport on firewall
sudo firewall-cmd --zone=public --permanent --add-port=${http_port}/tcp
sudo firewall-cmd --reload

