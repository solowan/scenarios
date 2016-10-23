#!/bin/bash

#
#  ncat running on 2121 or 2122 port
#
iptables -v -A FORWARD -t mangle -j NFQUEUE --queue-num 0 --queue-bypass -p TCP --dport 2121:2122
iptables -v -A FORWARD -t mangle -j NFQUEUE --queue-num 0 --queue-bypass -p TCP --sport 2121:2122

# 
# WEB: process traffic from or to port 80
#
iptables -v -A FORWARD -t mangle -j NFQUEUE --queue-num 0 --queue-bypass -p TCP --dport 80
iptables -v -A FORWARD -t mangle -j NFQUEUE --queue-num 0 --queue-bypass -p TCP --sport 80

#
# FTP: control traffic
#
iptables -v -A FORWARD -t mangle -j NFQUEUE --queue-num 0 --queue-bypass -p TCP --dport 21
iptables -v -A FORWARD -t mangle -j NFQUEUE --queue-num 0 --queue-bypass -p TCP --sport 21

#
# FTP: data traffic
#
iptables -v -A FORWARD -t mangle -j NFQUEUE --queue-num 0 --queue-bypass -p TCP --sport 9000:9499
iptables -v -A FORWARD -t mangle -j NFQUEUE --queue-num 0 --queue-bypass -p TCP --dport 9000:9499
