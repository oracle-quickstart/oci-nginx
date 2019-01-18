#!/bin/bash
set -e -x

# Install NGINX (nginx-1.12.2-2.el7.x86_64)
# The yum repo 'ol7_developer_EPEL' has been configured and enabled in Oracle 
# Linux Image 7 which can just run the 'yum install' command to install the nginx 
sudo yum install -y nginx-1.12.2-2.el7.x86_64

# Config nginx server Http Port
default_config_file="/etc/nginx/nginx.conf"
sudo sed -i -E "s/(listen.+)80(.+default_server;)/\1${http_port}\2/g" $${default_config_file}

# Start Nginx
sudo service nginx start 

# Set httpport on firewall
sudo firewall-cmd --zone=public --permanent --add-port=${http_port}/tcp
sudo firewall-cmd --reload

# config the ssl
if [ -e ${folder_path_for_ssl_cert_files} ] && [ -e ${ssl_cert_key_file_path} ] && [ -e ${ssl_cert_file_path} ]; then
    semanage permissive -a httpd_t
    temp_file="/tmp/nginx.conf_new"
    totalNumber=`cat $${default_config_file} | wc -l`
    lineNumber=`grep -n  listen $${default_config_file} | grep default_server | grep ${http_port} | tail -n1 | cut -d':' -f1`
    sudo head -n $${lineNumber} $${default_config_file} > $${temp_file}
    sudo echo """        listen ${https_port} ssl http2 default_server;
        listen [::]:${https_port} ssl http2 default_server;
        ssl_certificate \"${ssl_cert_file_path}\";
        ssl_certificate_key \"${ssl_cert_key_file_path}\";
        ssl_session_cache shared:SSL:1m;
        ssl_session_timeout  10m;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;
    """>> $${temp_file}
    sudo tail -n $(( $${totalNumber} - $${lineNumber} )) $${default_config_file} >> $${temp_file}

    sudo cp -f $${default_config_file} "$${default_config_file}_bak"
    sudo mv $${temp_file} $${default_config_file}

    sudo firewall-cmd --zone=public --permanent --add-port=${https_port}/tcp
    sudo firewall-cmd --reload
    sudo service nginx restart
fi