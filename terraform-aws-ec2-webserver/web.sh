#!/bin/bash

apt update
apt install wget unzip apache2 -y
systemctl start apache2
systemctl enable apache2
cd /tmp
wget https://www.tooplate.com/zip-templates/2150_living_parallax.zip
unzip -o 2150_living_parallax.zip
cp -r 2150_living_parallax/* /var/www/html/
systemctl restart apache2
