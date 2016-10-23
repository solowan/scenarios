#!/bin/bash
iptables -t mangle -L PREROUTING -nvx
iptables -t mangle -L POSTROUTING -nvx
