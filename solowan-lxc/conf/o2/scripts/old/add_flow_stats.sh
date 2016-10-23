#!/bin/bash
iptables -t mangle -I PREROUTING -p tcp -s $1 --sport $2 -d $3 --dport $4
iptables -t mangle -I POSTROUTING -p tcp -s $1 --sport $2 -d $3 --dport $4
