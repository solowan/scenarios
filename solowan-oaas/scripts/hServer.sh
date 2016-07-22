#!/bin/bash

apt-get -y update
apt-get -y install apache2 unzip
cd /var/www/html
wget -N http://sun.aei.polsl.pl/~sdeor/corpus/silesia.zip
unzip -o silesia.zip -d silesia
rm -f silesia.all
cat silesia/* > silesia.all
mkdir recibido


