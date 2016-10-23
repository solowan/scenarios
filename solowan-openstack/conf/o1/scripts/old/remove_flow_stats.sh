#!/bin/bash
iptables -t mangle -D PREROUTING -p tcp -s $1 --sport $2 -d $3 --dport $4
iptables -t mangle -D POSTROUTING -p tcp -s $1 --sport $2 -d $3 --dport $4
