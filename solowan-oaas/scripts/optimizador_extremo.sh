#!/bin/bash 
apt-get -y update
apt-get -y install git apache2 unzip
apt-get -y install make
git clone https://github.com/solowan/solowan.git
apt-get -y install autoconf autogen build-essential iptables libnetfilter-queue-dev libreadline-dev psmisc liblog4c-dev
cd solowan/opennop/opennop-daemon
./autogen.sh
./configure
make
make install
mkdir /etc/opennop
cp opennopd/opennop.conf /etc/opennop
etc/install.sh


cd /var/www/html
wget -N http://sun.aei.polsl.pl/~sdeor/corpus/silesia.zip
unzip -o silesia.zip -d silesia
rm -f silesia.all
cat silesia/* > silesia.all
mkdir recibido


#Cambiar localid en /etc/opennop/opennop.conf
